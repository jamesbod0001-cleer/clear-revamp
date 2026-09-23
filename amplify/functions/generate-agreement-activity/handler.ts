import {DynamoDBStreamHandler} from 'aws-lambda';
import {unmarshall} from '@aws-sdk/util-dynamodb';
import {Amplify} from 'aws-amplify';
import {generateClient} from 'aws-amplify/data';
import {getAmplifyDataClientConfig} from '@aws-amplify/backend/function/runtime';
import {env} from '$amplify/env/generate-agreement-activity';
import type {Schema} from '../../data/resource';
import {createActivityRecord} from '../shared/activity.utils';
import {Logger} from "@aws-lambda-powertools/logger";
import {formatCurrency} from "../shared/currency.utils";

const logger = new Logger({serviceName: "generate-agreement-activity"});
const {resourceConfig, libraryOptions} = await getAmplifyDataClientConfig(env);
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
                const newMilestoneId = newItem.activeMilestoneId;
                const oldMilestoneId = oldItem?.activeMilestoneId;
                const isMilestoneIdChanged = oldMilestoneId && newMilestoneId && (oldMilestoneId !== newMilestoneId);

                const newMilestoneStatus = newItem.activeMilestoneStatus;
                const oldMilestoneStatus = oldItem?.activeMilestoneStatus;
                const isMilestoneStatusChanged = newMilestoneStatus && (newMilestoneStatus !== oldMilestoneStatus);

                // Exit early if NOTHING changed
                if (!isStatusChanged && !isSenderJoined && !isDeliveryStatusChanged && !isMilestoneStatusChanged && !isMilestoneIdChanged) {
                    continue;
                }

                const initiatorRole = newItem.initiatorRole;
                const initiatorId = newItem.initiatorId;
                const senderId = newItem.senderId;
                const recipientId = newItem.recipientId;

                // Detect if the Deadline Sweeper made this change
                const isSystemUpdate = newItem.lastUpdatedBy === 'SYSTEM_DEADLINE_SWEEPER';

                const formattedAmount = formatCurrency(newItem.amount, newItem.currency);
                const description = newItem.description;

                const notify = async (
                    userId: string | undefined,
                    heading: string,
                    text: string,
                    type: 'AGREEMENT' | 'PAYMENT' | 'DELIVERY' | 'DISPUTE' = 'AGREEMENT',
                    amountOverride?: string,
                    descriptionOverride?: string
                ) => {
                    if (userId) {
                        await createActivityRecord(
                            client,
                            userId,
                            type,
                            heading,
                            text,
                            newItem.id,
                            amountOverride || formattedAmount,
                            descriptionOverride || description
                        );
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
                            await notify(initiatorId, 'Agreement Declined', 'This agreement has been declined. Your refund is being processed.');
                            await notify(recipientId, 'Agreement Declined', 'You have declined this agreement.');
                            break;
                        case 'CANCELLED':
                            await notify(initiatorId, 'Agreement Cancelled', 'You cancelled this agreement. Your refund is being processed.');
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
                // FLOW 3: PHYSICAL DELIVERY TRACKING
                // ==========================================
                if (isDeliveryStatusChanged && senderId && recipientId && !isSystemUpdate) {
                    const buyerId = senderId;
                    const vendorId = recipientId;

                    switch (newDeliveryStatus) {
                        case 'AWAITING_DISPATCH':
                            const hasPackagingPhotos = newItem.physicalDeliveryContext.packagingPhotos && newItem.physicalDeliveryContext.packagingPhotos.length > 0;
                            if (hasPackagingPhotos) {
                                await notify(vendorId, 'Packaging Photos Uploaded', 'Packaging photos have been uploaded for this agreement.', 'DELIVERY');
                                await notify(buyerId, 'Packaging Photos Uploaded', 'Packaging photos have been uploaded for this agreement.', 'DELIVERY');
                            } else {
                                await notify(vendorId, 'Packaging Skipped', 'You chose not to upload packaging photos.', 'DELIVERY');
                                await notify(buyerId, 'Packaging Skipped', 'Packaging photos were not added to this agreement.', 'DELIVERY');
                            }
                            break;

                        case 'AWAITING_BUYER_ACKNOWLEDGEMENT':
                            await notify(vendorId, 'Delivery Details Shared', 'Delivery details have been shared for this agreement.', 'DELIVERY');
                            await notify(buyerId, 'Delivery Details Shared', 'Delivery details have been shared for this agreement.', 'DELIVERY');
                            break;

                        case 'IN_TRANSIT':
                            if (oldDeliveryStatus === 'AWAITING_DISPATCH') {
                                await notify(vendorId, 'Delivery Details Skipped', 'You skipped sharing delivery details.', 'DELIVERY');
                                await notify(buyerId, 'Delivery Details Skipped', 'Delivery details were not provided for this agreement.', 'DELIVERY');
                            } else if (oldDeliveryStatus === 'AWAITING_BUYER_ACKNOWLEDGEMENT') {
                                await notify(vendorId, 'Delivery Details Confirmed', 'Delivery details have been acknowledged. This agreement is now awaiting delivery confirmation.', 'DELIVERY');
                                await notify(buyerId, 'Delivery Details Confirmed', 'You confirmed the delivery information. This agreement is now in transit.', 'DELIVERY');
                            }
                            break;
                    }
                }

                // ==========================================
                // FLOW 4: POST-FUNDING CORE STATUSES (Both Flows)
                // ==========================================
                // Once an agreement moves past FUNDED, the sender/recipient roles act exactly the same way.
                if (isStatusChanged && senderId && recipientId) {
                    switch (newStatus) {
                        case 'READY_FOR_RELEASE':
                            if (!isSystemUpdate) {
                                if (newItem.category === 'physical_goods') {
                                    await notify(senderId, 'Confirm Item Received', "Confirm receipt once you've received your item. You'll have 2 hours to report any issues after delivery.", 'AGREEMENT');
                                    await notify(recipientId, 'Awaiting Buyer Confirmation', 'Waiting for the buyer to confirm receipt of the item.', 'AGREEMENT');
                                } else {
                                    await notify(senderId, 'Approve Payment Release', 'The provider has marked this service as completed. Confirm completion to release the payment.', 'AGREEMENT');
                                    await notify(recipientId, 'Payment Requested', 'You marked this service as complete. Funds will be released once the client confirms completion.', 'AGREEMENT');
                                }
                            }
                            break;

                        case 'PROCESSING_RELEASE':
                            if (newItem.category === 'physical_goods') {
                                await notify(senderId, 'Release Initiated', 'You confirmed receipt of the item. Funds will be released in 2 hours.', 'PAYMENT');
                                await notify(recipientId, 'Item Received', 'The buyer confirmed receipt! Funds will be released to your payout destination in 2 hours.', 'PAYMENT');
                            } else {
                                await notify(senderId, 'Release Initiated', 'You approved the payment. Funds will be released in 2 hours.', 'PAYMENT');
                                await notify(recipientId, 'Payment Approved', 'The client approved the payment! Funds will be released to your payout destination in 2 hours.', 'PAYMENT');
                            }
                            break;

                        case 'RELEASED':
                            await notify(senderId, 'Agreement Completed', 'The agreement has been successfully completed.', 'AGREEMENT');
                            await notify(recipientId, 'Funds Released', 'The funds have been successfully released to your payout destination.', 'PAYMENT');
                            break;

                        case 'DISPUTED':
                            await notify(senderId, 'Issue Reported', 'An issue has been reported for this agreement. Funds remain securely held during review.', 'DISPUTE');
                            await notify(recipientId, 'Issue Reported', 'An issue has been reported for this agreement. Funds remain securely held during review.', 'DISPUTE');
                            break;
                    }
                }

                // ==========================================
                // FLOW 5: MILESTONE TRACKING
                // ==========================================
                if ((isMilestoneStatusChanged || isMilestoneIdChanged) && senderId && recipientId) {

                    // 5a. If the Milestone ID changed, the previous milestone successfully completed!
                    if (isMilestoneIdChanged) {
                        const oldMilestoneName = oldItem.activeMilestoneName || 'Milestone';
                        const oldMilestoneAmount = oldItem.activeMilestoneAmount || 0;
                        const formattedOldAmount = formatCurrency(oldMilestoneAmount, newItem.currency);

                        await notify(senderId, 'Milestone Completed', `${oldMilestoneName} has been successfully completed.`, 'AGREEMENT', formattedOldAmount, oldMilestoneName);
                        await notify(recipientId, 'Funds Released', `Funds for ${oldMilestoneName} have been released to your payout destination.`, 'PAYMENT', formattedOldAmount, oldMilestoneName);
                    }

                    // 5b. Evaluate the current milestone's status change
                    if (isMilestoneStatusChanged) {
                        const milestoneName = newItem.activeMilestoneName || 'Milestone';
                        const milestoneAmount = newItem.activeMilestoneAmount || 0;
                        const formattedMilestoneAmount = formatCurrency(milestoneAmount, newItem.currency);

                        switch (newMilestoneStatus) {
                            case 'IN_PROGRESS':
                                await notify(senderId, 'Milestone Active', `This milestone ${milestoneName} is now active, you’ll be notified once the provider marks it as completed.`, 'AGREEMENT', formattedMilestoneAmount, milestoneName);
                                await notify(recipientId, 'Milestone In Progress', `This milestone ${milestoneName} is now active. Notify your client when you've completed it.`, 'AGREEMENT', formattedMilestoneAmount, milestoneName);
                                break;

                            case 'READY_FOR_RELEASE':
                                if (!isSystemUpdate) {
                                    await notify(senderId, `Approve ${milestoneName}`, `The provider has finished ${milestoneName}. Review and approve the payment.`, 'AGREEMENT', formattedMilestoneAmount, milestoneName);
                                    await notify(recipientId, 'Milestone Submitted', `You have marked ${milestoneName} as finished. Waiting for client approval.`, 'AGREEMENT', formattedMilestoneAmount, milestoneName);
                                }
                                break;

                            case 'PROCESSING_RELEASE':
                                await notify(senderId, 'Release Initiated', `You approved payment for ${milestoneName}. Funds will be released in 2 hours.`, 'PAYMENT', formattedMilestoneAmount, milestoneName);
                                await notify(recipientId, 'Payment Approved', `The client approved ${milestoneName}! Funds will be released in 2 hours.`, 'PAYMENT', formattedMilestoneAmount, milestoneName);
                                break;

                            case 'RELEASED':
                                // This still fires for the FINAL milestone of the agreement (because the ID doesn't change)
                                await notify(senderId, 'Milestone Completed', `${milestoneName} has been successfully completed.`, 'AGREEMENT', formattedMilestoneAmount, milestoneName);
                                await notify(recipientId, 'Funds Released', `Funds for ${milestoneName} have been released to your payout destination.`, 'PAYMENT', formattedMilestoneAmount, milestoneName);
                                break;

                            case 'DISPUTED':
                                await notify(senderId, 'Milestone Disputed', `An issue has been reported for ${milestoneName}. Funds remain securely held during review.`, 'DISPUTE', formattedMilestoneAmount, milestoneName);
                                await notify(recipientId, 'Milestone Disputed', `An issue has been reported for ${milestoneName}. Funds remain securely held during review.`, 'DISPUTE', formattedMilestoneAmount, milestoneName);
                                break;
                        }
                    }
                }

            }
        } catch (error) {
            logger.error('Error generating activity', {error, recordId: record.eventID});
            if (record.dynamodb?.SequenceNumber) {
                batchItemFailures.push({itemIdentifier: record.dynamodb.SequenceNumber});
            }
        }
    }
    return {batchItemFailures};
};
