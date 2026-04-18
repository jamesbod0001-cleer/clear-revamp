import { DynamoDBStreamHandler } from 'aws-lambda';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/log-milestone-status';
import type { Schema } from '../../data/resource';
import { logStatusChange, logger } from '../shared/status.utils';

const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();

export const handler: DynamoDBStreamHandler = async (event) => {
    const batchItemFailures: { itemIdentifier: string }[] = [];

    for (const record of event.Records) {
        try {
            // Note: We don't even check if the status changed here anymore,
            // because our backend.ts filter will guarantee it!
            const newItem = unmarshall(record.dynamodb?.NewImage as any);
            const oldImage = record.dynamodb?.OldImage;
            const oldItem = oldImage ? unmarshall(oldImage as any) : null;

            await logStatusChange(
                client,
                newItem.id,
                'MILESTONE',
                oldItem ? oldItem.status : null,
                newItem.status,
                newItem.lastUpdatedBy || 'SYSTEM'
            );

        } catch (error) {
            logger.error('Error processing record', { error, recordId: record.eventID });
            if (record.dynamodb?.SequenceNumber) {
                batchItemFailures.push({ itemIdentifier: record.dynamodb.SequenceNumber });
            }
        }
    }

    return { batchItemFailures };
};
