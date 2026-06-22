import { DynamoDBStreamHandler } from 'aws-lambda';
import { DynamoDBClient, GetItemCommand } from '@aws-sdk/client-dynamodb';
import { PinpointClient, SendMessagesCommand } from '@aws-sdk/client-pinpoint';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ serviceName: "dispatch-activity-notification" });

const ddbClient = new DynamoDBClient({});
const pinpointClient = new PinpointClient({ region: process.env.PINPOINT_REGION });

export const handler: DynamoDBStreamHandler = async (event) => {
    const batchItemFailures: { itemIdentifier: string }[] = [];

    for (const record of event.Records) {
        if (record.eventName !== 'INSERT') continue;

        try {
            const activity = unmarshall(record.dynamodb?.NewImage as any);
            const { userId, heading, supportingText, entityId, type, id } = activity;

            if (!userId) {
                logger.warn('Activity record missing userId', { activityId: id });
                continue;
            }

            // 1. Look up User to get deviceToken
            const userResponse = await ddbClient.send(new GetItemCommand({
                TableName: process.env.USER_TABLE_NAME,
                Key: {
                    id: { S: userId }
                }
            }));

            if (!userResponse.Item) {
                logger.warn('User not found', { userId });
                continue;
            }

            const user = unmarshall(userResponse.Item);
            const deviceToken = user.deviceToken;

            if (!deviceToken) {
                logger.info('User has no deviceToken registered', { userId });
                continue;
            }

            // 2. Determine Platform (Apple APNs tokens are always 64-character hex strings)
            const isAppleToken = /^[0-9a-fA-F]{64}$/.test(deviceToken);
            const channelType = isAppleToken ? 'APNS' : 'GCM';

            // 3. Dispatch Push Notification via Pinpoint
            const pinpointResponse = await pinpointClient.send(new SendMessagesCommand({
                ApplicationId: process.env.PINPOINT_APP_ID,
                MessageRequest: {
                    Addresses: {
                        [deviceToken]: {
                            ChannelType: channelType
                        }
                    },
                    MessageConfiguration: {
                        // Configuration for Android devices
                        GCMMessage: {
                            Action: 'OPEN_APP',
                            Title: heading,
                            Body: supportingText,
                            Data: {
                                route: `/agreements/details/${entityId}`,
                                activityType: type,
                                activityId: id
                            },
                        },
                        // Configuration for Apple iOS devices
                        APNSMessage: {
                            Action: 'OPEN_APP',
                            Title: heading,
                            Body: supportingText,
                            Data: {
                                route: `/agreements/details/${entityId}`,
                                activityType: type,
                                activityId: id
                            },
                        }
                    }
                }
            }));

            const result = pinpointResponse.MessageResponse?.Result?.[deviceToken];
            if (result?.DeliveryStatus !== 'SUCCESSFUL') {
                logger.error('Failed to send push notification', {
                    userId,
                    platform: channelType,
                    deliveryStatus: result?.DeliveryStatus,
                    statusMessage: result?.StatusMessage
                });
            } else {
                logger.info('Push notification dispatched successfully', {
                    userId,
                    activityId: id,
                    platform: channelType
                });
            }

        } catch (error) {
            logger.error('Error processing Activity stream record', {
                error,
                recordId: record.eventID
            });
            if (record.dynamodb?.SequenceNumber) {
                batchItemFailures.push({ itemIdentifier: record.dynamodb.SequenceNumber });
            }
        }
    }

    return { batchItemFailures };
};
