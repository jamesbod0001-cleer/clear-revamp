import { DynamoDBStreamHandler } from 'aws-lambda';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/sync-milestone-to-agreement';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ serviceName: "sync-milestone-to-agreement" });
const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);

const client = generateClient<Schema>();

export const handler: DynamoDBStreamHandler = async (event) => {
    const batchItemFailures: { itemIdentifier: string }[] = [];

    for (const record of event.Records) {
        const sequenceNumber = record.dynamodb?.SequenceNumber;

        try {
            if (record.eventName === 'MODIFY' || record.eventName === 'INSERT') {
                const newMilestone = unmarshall(record.dynamodb?.NewImage as any);
                const oldMilestone = record.dynamodb?.OldImage ? unmarshall(record.dynamodb?.OldImage as any) : null;

                // Prevent infinite loops/wasted calls if status hasn't mutated
                if (oldMilestone && newMilestone.status === oldMilestone.status) {
                    continue;
                }

                const agreementId = newMilestone.agreementId;

                if (!agreementId) {
                    logger.warn(`Milestone ${newMilestone.id} has no agreementId attached. Skipping.`);
                    continue;
                }

                logger.info(`Milestone ${newMilestone.id} status changed. Calculating active milestone for Agreement ${agreementId}`);

                // ============================================================
                // 1. CALCULATE THE ACTIVE MILESTONE
                // ============================================================
                const { data: milestones, errors: fetchErrors } = await client.models.Milestone.list({
                    filter: { agreementId: { eq: agreementId } }
                });

                // Handle fetch errors safely without terminating the rest of the batch
                if (fetchErrors) {
                    logger.error('Failed to fetch milestones for agreement due to AppSync errors', { fetchErrors });
                    if (sequenceNumber) batchItemFailures.push({ itemIdentifier: sequenceNumber });
                    continue;
                }

                if (!milestones || milestones.length === 0) {
                    logger.warn(`No milestones found for Agreement ${agreementId}. Skipping.`);
                    continue;
                }

                // Sort milestones by explicit order field sequence
                const sortedMilestones = milestones.sort((a, b) => {
                    return (a.order || 0) - (b.order || 0);
                });

                // Locate the lowest incomplete milestone
                const activeMilestone = sortedMilestones.find(m => m.status !== 'RELEASED');

                // Fall back to the terminal milestone if everything has been released
                const milestoneToSync = activeMilestone || sortedMilestones[sortedMilestones.length - 1];

                // ============================================================
                // 2. UPDATE THE PARENT AGREEMENT
                // ============================================================
                logger.info(`Syncing active Milestone ${milestoneToSync.id} (${milestoneToSync.status}) to Agreement ${agreementId}`);

                const { errors: updateErrors } = await client.models.Agreement.update({
                    id: agreementId,
                    activeMilestoneId: milestoneToSync.id,
                    activeMilestoneStatus: milestoneToSync.status,
                    activeMilestoneName: milestoneToSync.name || `Milestone`,
                    activeMilestoneAmount: milestoneToSync.amount,
                    activeMilestoneExpectedReleaseDate: milestoneToSync.expectedReleaseDate,
                    lastUpdatedBy: milestoneToSync.lastUpdatedBy
                });

                // Explicit failure handling without throwing caught exceptions locally
                if (updateErrors) {
                    logger.error('AppSync update errors on parent Agreement table update', { updateErrors });
                    if (sequenceNumber) batchItemFailures.push({ itemIdentifier: sequenceNumber });

                }
            }
        } catch (error) {
            logger.error('Unexpected native crash syncing milestone to agreement', { error, recordId: record.eventID });
            if (sequenceNumber) {
                batchItemFailures.push({ itemIdentifier: sequenceNumber });
            }
        }
    }

    // Always returns at the very end to guarantee every item in the batch gets checked
    return { batchItemFailures };
};
