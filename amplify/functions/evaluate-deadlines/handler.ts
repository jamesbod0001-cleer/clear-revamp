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
        // FIX: Track items we update today so we don't double-notify them in Blocks 2 & 4
        const processedAgreementIds = new Set<string>();
        const processedMilestoneIds = new Set<string>();

        // =========================================================
        // 1. FAST-FORWARD IN_PROGRESS AGREEMENTS & NUDGE BOTH PARTIES
        // =========================================================
        const { data: inProgressAgreements } = await client.models.Agreement.list({
            filter: { status: { eq: "IN_PROGRESS" }, expectedReleaseDate: { le: today } }
        });

        for (const agreement of inProgressAgreements) {
            // FIX: Handle category casing securely
            const isPhysicalGoods = agreement.category === 'physical_goods' || agreement.category === 'PHYSICAL_GOODS';
            const deliveryStatus = agreement.physicalDeliveryContext?.status;

            // If the vendor shared details, but the buyer hasn't acknowledged, DO NOT FAST FORWARD.
            if (isPhysicalGoods && deliveryStatus === 'AWAITING_BUYER_ACKNOWLEDGEMENT') {
                logger.info(`Agreement ${agreement.id} is stuck awaiting buyer acknowledgement. Halting fast-forward.`);

                if (agreement.senderId) {
                    await createActivityRecord(client, agreement.senderId, 'AGREEMENT', 'Action Required', 'The deadline has passed, but you must acknowledge the delivery details before the vendor can dispatch the item.', agreement.id, formatCurrency(agreement.amount, agreement.currency), agreement.description || '');
                }
                if (agreement.recipientId) {
                    await createActivityRecord(client, agreement.recipientId, 'AGREEMENT', 'Awaiting Buyer', 'The deadline has passed, but we are still waiting for the buyer to acknowledge your delivery details.', agreement.id, formatCurrency(agreement.amount, agreement.currency), agreement.description || '');
                }
                continue; // Skip the rest of this loop and move to the next agreement
            }

            // Normal Fast-Forward Logic for Services or Safe Physical Goods
            logger.info(`Fast-forwarding Agreement ${agreement.id} to READY_FOR_RELEASE`);

            const updatedFields: any = {
                id: agreement.id,
                status: "READY_FOR_RELEASE",
                lastUpdatedBy: systemUpdaterId
            };

            if (isPhysicalGoods && agreement.physicalDeliveryContext) {
                updatedFields.physicalDeliveryContext = {
                    ...agreement.physicalDeliveryContext,
                    status: "IN_TRANSIT"
                };
            }

            await client.models.Agreement.update(updatedFields);

            // Add to Set after successfully updating
            processedAgreementIds.add(agreement.id);

            // FIX: Dynamic Notifications based on Category
            if (isPhysicalGoods) {
                if (agreement.recipientId) {
                    await createActivityRecord(client, agreement.recipientId, 'AGREEMENT', "Agreement Auto-Advanced", "Your due date has passed! The system advanced this agreement. If you haven't shipped the item yet, contact your buyer immediately.", agreement.id, formatCurrency(agreement.amount, agreement.currency), agreement.description || '');
                }
                if (agreement.senderId) {
                    await createActivityRecord(client, agreement.senderId, 'AGREEMENT', "Deadline Reached", "The due date has arrived and the system advanced the agreement. Please confirm receipt of your item or open a dispute.", agreement.id, formatCurrency(agreement.amount, agreement.currency), agreement.description || '');
                }
            } else {
                if (agreement.recipientId) {
                    await createActivityRecord(client, agreement.recipientId, 'AGREEMENT', "Agreement Auto-Advanced", "Your due date has passed! The system advanced this agreement. If you haven't completed the service, contact your client immediately.", agreement.id, formatCurrency(agreement.amount, agreement.currency), agreement.description || '');
                }
                if (agreement.senderId) {
                    await createActivityRecord(client, agreement.senderId, 'AGREEMENT', "Deadline Reached", "The due date has arrived and the system advanced the agreement. Please review the service and release funds, or open a dispute.", agreement.id, formatCurrency(agreement.amount, agreement.currency), agreement.description || '');
                }
            }
        }

        // =========================================================
        // 2. NUDGE CLIENTS FOR ALREADY 'READY_FOR_RELEASE' AGREEMENTS
        // =========================================================
        const { data: readyAgreements } = await client.models.Agreement.list({
            filter: { status: { eq: "READY_FOR_RELEASE" }, expectedReleaseDate: { le: today } }
        });

        for (const agreement of readyAgreements) {
            // FIX: Skip this agreement if we just advanced it in Block 1
            if (processedAgreementIds.has(agreement.id)) continue;

            const isPhysicalGoods = agreement.category === 'physical_goods' || agreement.category === 'PHYSICAL_GOODS';

            if (agreement.senderId) {
                await createActivityRecord(
                    client,
                    agreement.senderId,
                    'AGREEMENT',
                    "Payment Reminder",
                    isPhysicalGoods ? "The due date for this agreement has passed. Have you received your item? Please release the funds or open a dispute." : "The due date for this agreement has passed. Have you received your service? Please release the funds or open a dispute.",
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

            // Add to Set after successfully updating
            processedMilestoneIds.add(milestone.id);

            const { data: agreement } = await milestone.agreement();
            if (agreement && agreement.recipientId) {
                await createActivityRecord(
                    client,
                    agreement.recipientId,
                    'AGREEMENT',
                    "Milestone Auto-Advanced",
                    `The due date for "${milestone.name}" has passed. It was automatically advanced. Please notify your client if there are delays.`,
                    agreement.id,
                    formatCurrency(milestone.amount, agreement.currency),
                    milestone.name
                );
            }
            if (agreement && agreement.senderId) {
                await createActivityRecord(
                    client,
                    agreement.senderId,
                    'AGREEMENT',
                    "Milestone Deadline Reached",
                    `The due date for "${milestone.name}" has arrived and was auto-advanced. Please review the work and release the funds, or open a dispute.`,
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
            // FIX: Skip this milestone if we just advanced it in Block 3
            if (processedMilestoneIds.has(milestone.id)) continue;

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
