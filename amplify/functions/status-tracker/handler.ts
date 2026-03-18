// amplify/functions/status-tracker/handler.ts
import { DynamoDBStreamHandler } from 'aws-lambda';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/status-tracker';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({
    logLevel: "INFO",
    serviceName: "status-tracker-handler",
});

const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);

const client = generateClient<Schema>();

export const handler: DynamoDBStreamHandler = async (event) => {
    logger.info(`Received ${event.Records.length} records from stream.`);

    // Initialize the array to hold any failed sequence numbers
    const batchItemFailures: { itemIdentifier: string }[] = [];

    for (const record of event.Records) {
        logger.info(`Processing record ID: ${record.eventID}`, { eventName: record.eventName });

        try {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                const newItem = unmarshall(record.dynamodb?.NewImage as any);
                const oldImage = record.dynamodb?.OldImage;
                const oldItem = oldImage ? unmarshall(oldImage as any) : null;

                const isStatusChanged = record.eventName === 'INSERT' || (oldItem && oldItem.status !== newItem.status);

                if (isStatusChanged) {
                    const isMilestone = record.eventSourceARN?.includes('Milestone');

                    logger.info(`Detected status change for ${isMilestone ? 'Milestone' : 'Agreement'}`, {
                        itemId: newItem.id,
                        oldStatus: oldItem ? oldItem.status : 'NONE',
                        newStatus: newItem.status
                    });

                    // Execute the GraphQL Mutation
                    const { data, errors } = await client.models.StatusHistory.create({
                        oldStatus: oldItem ? oldItem.status : null,
                        newStatus: newItem.status,
                        changedBy: newItem.lastUpdatedBy || 'SYSTEM',
                        milestoneId: isMilestone ? newItem.id : undefined,
                        agreementId: !isMilestone ? newItem.id : undefined,
                    });

                    if (errors) {
                        logger.error('AppSync rejected the creation (GraphQL Error)', { errors });
                        // If AppSync rejects it, push the SequenceNumber to the failure list
                        if (record.dynamodb?.SequenceNumber) {
                            batchItemFailures.push({ itemIdentifier: record.dynamodb.SequenceNumber });
                        }
                    } else {
                        logger.info('Successfully created StatusHistory record via AppSync', { historyId: data?.id });
                    }
                } else {
                    logger.debug(`Status unchanged for item ${newItem.id}. Skipping history creation.`);
                }
            }
        } catch (error) {
            logger.error('Severe error processing record', { error, recordId: record.eventID });
            // Catch severe network errors and flag the record for retry
            if (record.dynamodb?.SequenceNumber) {
                batchItemFailures.push({ itemIdentifier: record.dynamodb.SequenceNumber });
            }
        }
    }

    // Return the exact array of failures back to DynamoDB
    return { batchItemFailures };
};
