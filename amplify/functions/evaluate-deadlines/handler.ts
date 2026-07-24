import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/evaluate-deadlines';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";
import { createActivityRecord } from '../shared/activity.utils';
import { formatCurrency } from '../shared/currency.utils';

const logger = new Logger({ serviceName: "evaluate-deadlines-sweeper" });
const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();

export const handler = async (_event: any) => {
    logger.info("Starting Daily Deadline Sweeper (9:00 AM WAT)");

    const today = new Date().toISOString().split('T')[0];
    const systemUpdaterId = "SYSTEM_DEADLINE_SWEEPER";

    try {
        // =========================================================
        // 1. FAST-FORWARD IN_PROGRESS AGREEMENTS & NUDGE VENDORS
        // =========================================================
        const { data: inProgressAgreements } = await client.models.Agreement.list({
            filter: { status: { eq: "IN_PROGRESS" }, expectedReleaseDate: { le: today } }
        });

        for (const agreement of inProgressAgreements) {
            logger.info(`Fast-forwarding Agreement ${agreement.id} to READY_FOR_RELEASE`);

            const updatedFields: any = {
                id: agreement.id,
                status: "READY_FOR_RELEASE",
                lastUpdatedBy: systemUpdaterId
            };

            if (agreement.category === 'PHYSICAL_GOODS' && agreement.physicalDeliveryContext) {
                updatedFields.physicalDeliveryContext = {
                    ...agreement.physicalDeliveryContext,
                    status: "IN_TRANSIT"
                };
            }

            await client.models.Agreement.update(updatedFields);

            if (agreement.recipientId) {
                await createActivityRecord(
                    client,
                    agreement.recipientId,
                    'AGREEMENT',
                    "Action Required: Overdue Agreement",
                    "Your due date has passed! We automatically advanced the agreement. If you haven't delivered yet, please contact your client immediately to avoid a dispute.",
                    agreement.id,
                    formatCurrency(agreement.amount, agreement.currency),
                    agreement.description || ''
                );
            }
        }

        // =========================================================
        // 2. NUDGE CLIENTS FOR ALREADY 'READY_FOR_RELEASE' AGREEMENTS
        // =========================================================
        const { data: readyAgreements } = await client.models.Agreement.list({
            filter: { status: { eq: "READY_FOR_RELEASE" }, expectedReleaseDate: { le: today } }
        });

        for (const agreement of readyAgreements) {
            if (agreement.senderId) {
                await createActivityRecord(
                    client,
                    agreement.senderId,
                    'AGREEMENT',
                    "Payment Reminder",
                    "The due date for this agreement has passed. Have you received your service/item? Please release the funds or open a dispute.",
                    agreement.id,
                    formatCurrency(agreement.amount, agreement.currency),
                    agreement.description || ''
                );
            }
        }

        // =========================================================
        // 3. FAST-FORWARD OVERDUE ACTIVE MILESTONES & NUDGE VENDORS
        // =========================================================
        const { data: activeMilestones } = await client.models.Milestone.list({
            filter: { status: { eq: "IN_PROGRESS" }, expectedReleaseDate: { le: today } }
        });

        for (const milestone of activeMilestones) {
            logger.info(`Fast-forwarding Milestone ${milestone.id} to READY_FOR_RELEASE`);

            await client.models.Milestone.update({
                id: milestone.id,
                status: "READY_FOR_RELEASE",
                lastUpdatedBy: systemUpdaterId
            });

            const { data: agreement } = await milestone.agreement();
            if (agreement && agreement.recipientId) {
                await createActivityRecord(
                    client,
                    agreement.recipientId,
                    'AGREEMENT',
                    "Milestone Overdue",
                    `The due date for milestone "${milestone.name}" has passed. It has been advanced to Ready for Release. Please notify your client if there are delays.`,
                    agreement.id,
                    formatCurrency(milestone.amount, agreement.currency),
                    milestone.name
                );
            }
        }

        // =========================================================
        // 4. NUDGE CLIENTS FOR OVERDUE 'READY_FOR_RELEASE' MILESTONES
        // =========================================================
        const { data: readyMilestones } = await client.models.Milestone.list({
            filter: { status: { eq: "READY_FOR_RELEASE" }, expectedReleaseDate: { le: today } }
        });

        for (const milestone of readyMilestones) {
            const { data: agreement } = await milestone.agreement();
            if (agreement && agreement.senderId) {
                await createActivityRecord(
                    client,
                    agreement.senderId,
                    'AGREEMENT',
                    "Milestone Payment Reminder",
                    `The due date for milestone "${milestone.name}" has passed. Please review the work and release the funds, or open a dispute.`,
                    agreement.id,
                    formatCurrency(milestone.amount, agreement.currency),
                    milestone.name
                );
            }
        }

        logger.info("Daily Deadline Sweeper completed successfully.");
        return { success: true };

    } catch (error) {
        logger.error("Deadline Sweeper encountered an error", { error });
        return { success: false, error };
    }
};
