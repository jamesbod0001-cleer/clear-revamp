import { DynamoDBStreamHandler } from 'aws-lambda';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/generate-agreement-activity';
import type { Schema } from '../../data/resource';
import { createActivityRecord } from '../shared/activity.utils';
import { Logger } from "@aws-lambda-powertools/logger";
import { formatCurrency } from "../shared/currency.utils";

const logger = new Logger({ serviceName: "generate-agreement-activity" });
const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();

export const handler: DynamoDBStreamHandler = async (event) => {
    const batchItemFailures: { itemIdentifier: string }[] = [];

    for (const record of event.Records) {
        try {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                const newItem = unmarshall(record.dynamodb?.NewImage as any);
                const oldItem = record.dynamodb?.OldImage ? unmarshall(record.dynamodb?.OldImage as any) : null;

                // 1. Check Core Agreement Status
                const newStatus = newItem.status;
                const oldStatus = oldItem?.status;
                const isStatusChanged = newStatus !== oldStatus;
                const isSenderJoined = !oldItem?.senderId && newItem.senderId;

                // 2. Check Physical Delivery Context Status
                const newDeliveryStatus = newItem.physicalDeliveryContext?.status;
                const oldDeliveryStatus = oldItem?.physicalDeliveryContext?.status;
                const isDeliveryStatusChanged = newDeliveryStatus && (newDeliveryStatus !== oldDeliveryStatus);

                // 3. Check Active Milestone Status (NoSQL Denormalization)
                const newMilestoneStatus = newItem.activeMilestoneStatus;
                const oldMilestoneStatus = oldItem?.activeMilestoneStatus;
                const isMilestoneStatusChanged = newMilestoneStatus && (newMilestoneStatus !== oldMilestoneStatus);

                // Exit early if NOTHING changed
                if (!isStatusChanged && !isSenderJoined && !isDeliveryStatusChanged && !isMilestoneStatusChanged) {
                    continue;
                }

                const initiatorRole = newItem.initiatorRole;
                const initiatorId = newItem.initiatorId;
                const senderId = newItem.senderId;
                const recipientId = newItem.recipientId;

                const formattedAmount = formatCurrency(newItem.amount, newItem.currency);
                const description = newItem.description;

                const notify = async (userId: string | undefined, heading: string, text: string, type: 'AGREEMENT' | 'PAYMENT' | 'DELIVERY' = 'AGREEMENT') => {
                    if (userId) {
                        await createActivityRecord(client, userId, type, heading, text, newItem.id, formattedAmount, description);
                    }
                };

                // ==========================================
                // FLOW 1: INITIATOR IS THE SENDER (Send Funds)
                // ==========================================
                if (initiatorRole === 'SENDER' && isStatusChanged) {
                    switch (newStatus) {
                        case 'AWAITING_RECIPIENT':
                            await notify(initiatorId, 'Agreement Created', 'You have successfully created a send funds agreement.');
                            await notify(initiatorId, 'Funds Secured', 'Your funds have been securely locked in escrow.', 'PAYMENT');
                            await notify(recipientId, 'Agreement Received', 'You have received an agreement to review.');
                            break;
                        case 'FUNDED':
                            await notify(initiatorId, 'Agreement Accepted', 'The recipient has accepted your agreement.');
                            await notify(recipientId, 'Agreement Accepted', 'You have accepted the agreement.');
                            break;
                        case 'REJECTED':
                            await notify(initiatorId, 'Agreement Declined', 'This agreement has been declined.');
                            await notify(recipientId, 'Agreement Declined', 'You have declined this agreement.');
                            break;
                        case 'CANCELLED':
                            await notify(initiatorId, 'Agreement Cancelled', 'You cancelled this agreement.');
                            break;
                    }
                }

                    // ==========================================
                    // FLOW 2: INITIATOR IS THE RECIPIENT (Request Payment)
                // ==========================================
                else if (initiatorRole === 'RECIPIENT') {
                    if (isStatusChanged && newStatus === 'AWAITING_FUNDING' && (!oldStatus || oldStatus === 'DRAFT')) {
                        await notify(initiatorId, 'Agreement Created', 'You have successfully created a payment request.');
                    }
                    if (isSenderJoined) {
                        await notify(initiatorId, 'Agreement Accepted', 'The sender has accepted your request and will make payment.');
                        await notify(senderId, 'Agreement Accepted', 'You have accepted the payment request.');
                    }
                    if (isStatusChanged) {
                        switch (newStatus) {
                            case 'FUNDED':
                                await notify(initiatorId, 'Funds Secured', 'The sender has successfully secured the funds in escrow.', 'PAYMENT');
                                await notify(senderId, 'Funds Secured', 'Your funds have been securely locked in escrow.', 'PAYMENT');
                                break;
                            case 'REJECTED':
                                await notify(initiatorId, 'Agreement Declined', 'This payment request was declined.');
                                await notify(senderId, 'Agreement Declined', 'You have declined this payment request.');
                                break;
                            case 'CANCELLED':
                                await notify(initiatorId, 'Agreement Cancelled', 'You cancelled this payment request.');
                                break;
                        }
                    }
                }

                // ==========================================
                // FLOW 3: POST-FUNDING CORE STATUSES (Both Flows)
                // ==========================================
                // Once an agreement moves past FUNDED, the sender/recipient roles act exactly the same way.
                if (isStatusChanged && senderId && recipientId) {
                    switch (newStatus) {
                        case 'IN_PROGRESS':
                            if (newItem.category === 'physical_goods') {
                                await notify(senderId, 'Packaging Started', 'The vendor has started preparing your order for dispatch.', 'AGREEMENT');
                            } else {
                                await notify(senderId, 'Work Started', 'The provider has officially begun working on your service.', 'AGREEMENT');
                                await notify(recipientId, 'Service In Progress', 'You have officially started the work. The client has been notified.', 'AGREEMENT');
                            }
                            break;

                        case 'READY_FOR_RELEASE':
                            // I am thinking that because of this in transit notifications sent the user should not receive another notification again when in ready for release for physical goods
                            if (newItem.category === 'physical_goods') {
                                await notify(senderId, 'Confirm Item Received', 'Your item is on its way. Please confirm receipt once it arrives to release the funds.', 'AGREEMENT');
                                await notify(recipientId, 'Awaiting Buyer Confirmation', 'The buyer has been notified to confirm receipt of the item.', 'AGREEMENT');
                            } else {
                                await notify(senderId, 'Approve Payment Release', 'The provider has marked the agreed work as finished. Please approve their payment.', 'AGREEMENT');
                                await notify(recipientId, 'Payment Requested', 'You have marked the work as finished. Waiting for the client to approve payment.', 'AGREEMENT');
                            }
                            break;

                        case 'PROCESSING_RELEASE':
                            if (newItem.category === 'physical_goods') {
                                await notify(senderId, 'Release Initiated', 'You confirmed receipt of the item. Funds will be released in 2 hours.', 'PAYMENT');
                                await notify(recipientId, 'Item Received', 'The buyer confirmed receipt! Funds will be released to your wallet in 2 hours.', 'PAYMENT');
                            } else {
                                await notify(senderId, 'Release Initiated', 'You approved the payment. Funds will be released in 2 hours.', 'PAYMENT');
                                await notify(recipientId, 'Payment Approved', 'The client approved the payment! Funds will be released to your wallet in 2 hours.', 'PAYMENT');
                            }
                            break;

                        case 'RELEASED':
                            await notify(senderId, 'Agreement Completed', 'The agreement has been successfully completed.', 'AGREEMENT');
                            await notify(recipientId, 'Funds Released', 'The funds have been successfully released to your wallet.', 'PAYMENT');
                            break;
                    }
                }

                // ==========================================
                // FLOW 4: PHYSICAL DELIVERY TRACKING
                // ==========================================
                if (isDeliveryStatusChanged && senderId && recipientId) {
                    const buyerId = senderId;
                    const vendorId = recipientId;

                    switch (newDeliveryStatus) {
                        case 'AWAITING_DISPATCH':
                            const hasPackagingPhotos = newItem.physicalDeliveryContext.packagingPhotos && newItem.physicalDeliveryContext.packagingPhotos.length > 0;
                            if (hasPackagingPhotos) {
                                await notify(vendorId, 'Packaging Uploaded', 'You uploaded the packaging photos.', 'DELIVERY');
                                await notify(buyerId, 'Packaging Uploaded', 'Vendor has uploaded the packaging photos.', 'DELIVERY');
                            } else {
                                await notify(vendorId, 'Packaging Skipped', 'You skipped uploading packaging photos.', 'DELIVERY');
                                await notify(buyerId, 'Packaging Skipped', 'Vendor skipped uploading packaging photos.', 'DELIVERY');
                            }
                            break;

                        case 'AWAITING_BUYER_ACKNOWLEDGEMENT':
                            await notify(vendorId, 'Details Shared', 'You shared the delivery details.', 'DELIVERY');
                            await notify(buyerId, 'Details Shared', 'Vendor has shared the delivery details for your review.', 'DELIVERY');
                            break;

                        case 'IN_TRANSIT':
                            // I am thinking that because of this in transit notifications sent the user should not receive another notification again when in ready for release for physical goods
                            if (oldDeliveryStatus === 'AWAITING_DISPATCH') {
                                await notify(vendorId, 'Details Skipped', 'You skipped sharing delivery details.', 'DELIVERY');
                                await notify(buyerId, 'Details Skipped', 'Vendor skipped sharing delivery details. Item is in transit.', 'DELIVERY');
                            } else if (oldDeliveryStatus === 'AWAITING_BUYER_ACKNOWLEDGEMENT') {
                                await notify(vendorId, 'Details Confirmed', 'Buyer acknowledged the delivery details. Item is now in transit.', 'DELIVERY');
                                await notify(buyerId, 'Details Confirmed', 'You acknowledged the delivery details. Item is in transit.', 'DELIVERY');
                            }
                            break;
                    }
                }

                // ==========================================
                // FLOW 5: MILESTONE TRACKING
                // ==========================================
                if (isMilestoneStatusChanged && senderId && recipientId) {
                    const milestoneName = newItem.activeMilestoneName || 'Milestone';

                    switch (newMilestoneStatus) {
                        case 'IN_PROGRESS':
                            await notify(senderId, 'Milestone Started', `The provider has begun working on ${milestoneName}.`, 'AGREEMENT');
                            await notify(recipientId, 'Milestone In Progress', `You started working on ${milestoneName}.`, 'AGREEMENT');
                            break;

                        case 'READY_FOR_RELEASE':
                            await notify(senderId, `Approve ${milestoneName}`, `The provider has finished ${milestoneName}. Please review and approve the payment.`, 'AGREEMENT');
                            await notify(recipientId, 'Milestone Submitted', `You have marked ${milestoneName} as finished. Waiting for client approval.`, 'AGREEMENT');
                            break;

                        case 'PROCESSING_RELEASE':
                            await notify(senderId, 'Release Initiated', `You approved payment for ${milestoneName}. Funds will be released in 2 hours.`, 'PAYMENT');
                            await notify(recipientId, 'Payment Approved', `The client approved ${milestoneName}! Funds will be released in 2 hours.`, 'PAYMENT');
                            break;

                        case 'RELEASED':
                            await notify(senderId, 'Milestone Completed', `${milestoneName} has been successfully completed.`, 'AGREEMENT');
                            await notify(recipientId, 'Funds Released', `Funds for ${milestoneName} have been released to your wallet.`, 'PAYMENT');
                            break;
                    }
                }

            }
        } catch (error) {
            logger.error('Error generating activity', { error, recordId: record.eventID });
            if (record.dynamodb?.SequenceNumber) {
                batchItemFailures.push({ itemIdentifier: record.dynamodb.SequenceNumber });
            }
        }
    }
    return { batchItemFailures };
};
