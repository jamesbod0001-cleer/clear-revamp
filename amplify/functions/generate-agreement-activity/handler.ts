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

                // Exit early if NOTHING changed
                if (!isStatusChanged && !isSenderJoined && !isDeliveryStatusChanged) continue;

                const initiatorRole = newItem.initiatorRole;
                const initiatorId = newItem.initiatorId;
                const senderId = newItem.senderId;
                const recipientId = newItem.recipientId;

                const formattedAmount = formatCurrency(newItem.amount, newItem.currency);
                const description = newItem.description;

                // Note: Added 'DELIVERY' to the allowed types
                const notify = async (userId: string | undefined, heading: string, text: string, type: 'AGREEMENT' | 'PAYMENT' | 'DELIVERY' = 'AGREEMENT') => {
                    if (userId) {
                        await createActivityRecord(client, userId, type, heading, text, newItem.id, formattedAmount, description);
                    }
                };

                // ==========================================
                // FLOW 1: INITIATOR IS THE SENDER (Send Funds)
                // ==========================================
                if (initiatorRole === 'SENDER') {
                    if (isStatusChanged) {
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
                if (isDeliveryStatusChanged && senderId && recipientId) {

                    // Note: In physical goods, the Vendor is ALWAYS the Recipient of the funds,
                    // and the Buyer is ALWAYS the Sender of the funds.
                    const buyerId = senderId;
                    const vendorId = recipientId;

                    switch (newDeliveryStatus) {
                        case 'AWAITING_DISPATCH':
                            // Determine if they skipped based on whether packaging photos exist
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
                            // This state only happens if the vendor explicitly provided details
                            await notify(vendorId, 'Details Shared', 'You shared the delivery details.', 'DELIVERY');
                            await notify(buyerId, 'Details Shared', 'Vendor has shared the delivery details for your review.', 'DELIVERY');
                            break;

                        case 'IN_TRANSIT':
                            // We can reach IN_TRANSIT from two places: Awaiting Dispatch (Skipped) or Awaiting Buyer Acknowledgement (Confirmed)
                            if (oldDeliveryStatus === 'AWAITING_DISPATCH') {
                                // Vendor skipped the details step entirely
                                await notify(vendorId, 'Details Skipped', 'You skipped sharing delivery details.', 'DELIVERY');
                                await notify(buyerId, 'Details Skipped', 'Vendor skipped sharing delivery details. Item is in transit.', 'DELIVERY');
                            } else if (oldDeliveryStatus === 'AWAITING_BUYER_ACKNOWLEDGEMENT') {
                                // Buyer clicked acknowledge
                                await notify(vendorId, 'Details Confirmed', 'Buyer acknowledged the delivery details. Item is now in transit.', 'DELIVERY');
                                await notify(buyerId, 'Details Confirmed', 'You acknowledged the delivery details. Item is in transit.', 'DELIVERY');
                            }
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
