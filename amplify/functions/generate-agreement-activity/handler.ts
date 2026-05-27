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

                const newStatus = newItem.status;
                const oldStatus = oldItem ? oldItem.status : null;

                const isStatusChanged = newStatus !== oldStatus;
                const isSenderJoined = !oldItem?.senderId && newItem.senderId;

                if (!isStatusChanged && !isSenderJoined) continue;

                const initiatorRole = newItem.initiatorRole;
                const initiatorId = newItem.initiatorId;
                const senderId = newItem.senderId;
                const recipientId = newItem.recipientId;

                const formattedAmount = formatCurrency(newItem.amount, newItem.currency);
                const description = newItem.description;

                const notify = async (userId: string | undefined, heading: string, text: string, type: 'AGREEMENT' | 'PAYMENT' = 'AGREEMENT') => {
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
                                // 1. First, tell the Sender the agreement was officially created
                                await notify(initiatorId, 'Agreement Created', 'You have successfully created a send funds agreement.');

                                // 2. Immediately tell the Sender the funds are secured
                                await notify(initiatorId, 'Funds Secured', 'Your funds have been securely locked in escrow.', 'PAYMENT');

                                // 3. Notify the Recipient (if they are a registered user)
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
                    // Scenario A: Creation (Moves to AWAITING_FUNDING immediately)
                    if (isStatusChanged && newStatus === 'AWAITING_FUNDING' && (!oldStatus || oldStatus === 'DRAFT')) {
                        await notify(initiatorId, 'Agreement Created', 'You have successfully created a payment request.');
                    }

                    // Scenario B: Sender Accepts (Status doesn't change, but senderId is populated)
                    if (isSenderJoined) {
                        await notify(initiatorId, 'Agreement Accepted', 'The sender has accepted your request and will make payment.');
                        await notify(senderId, 'Agreement Accepted', 'You have accepted the payment request.');
                    }

                    // Scenario C: Sender Pays / Agreement Updates
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
