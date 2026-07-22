import { generateClient } from 'aws-amplify/data';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ serviceName: "db-utils" });
const client = generateClient<Schema>();

export async function getAgreement(agreementId: string) {
    const { data, errors } = await client.models.Agreement.get({ id: agreementId });
    if (errors) throw new Error(`Failed to get agreement: ${JSON.stringify(errors)}`);
    return data;
}

export async function findTransactionByRef(reference: string) {
    const { data, errors } = await client.models.Transaction.list({
        filter: { reference: { eq: reference } }
    });
    if (errors) logger.error('Failed to list transactions', { errors });
    return data?.[0];
}

export async function updatePaymentSuccess(
    transactionId: string,
    agreementId: string,
    nextStatus: any,
    disbursementType: string
) {
    const updaterIdentifier = 'FLUTTERWAVE_WEBHOOK';

    // 1. Update Transaction
    const txUpdate = await client.models.Transaction.update({
        id: transactionId,
        status: 'SUCCESSFUL'
    });
    if (txUpdate.errors) logger.error('Failed to update Transaction', { errors: txUpdate.errors });

    // 2. Update Agreement Status & leave Audit Trail
    const agreeUpdate = await client.models.Agreement.update({
        id: agreementId,
        status: nextStatus,
        lastUpdatedBy: updaterIdentifier
    });
    if (agreeUpdate.errors) logger.error('Failed to update Agreement', { errors: agreeUpdate.errors });

    // 3. Handle Milestones if needed
    if (nextStatus === 'FUNDED') {
        const progressUpdate = await client.models.Agreement.update({
            id: agreementId,
            status: 'IN_PROGRESS',
            lastUpdatedBy: updaterIdentifier
        });
        if (progressUpdate.errors) logger.error('Failed to update Agreement to IN_PROGRESS', { errors: progressUpdate.errors });

        if (disbursementType === 'MILESTONES') {
            const { data: milestones } = await client.models.Milestone.list({
                filter: { agreementId: { eq: agreementId }, order: { eq: 0 } }
            });

            if (milestones?.[0]) {
                const msUpdate = await client.models.Milestone.update({
                    id: milestones[0].id,
                    status: 'IN_PROGRESS',
                    lastUpdatedBy: updaterIdentifier
                });
                if (msUpdate.errors) logger.error('Failed to update Milestone', { errors: msUpdate.errors });
            }
        }
    }
}

export async function updateTransactionFailed(transactionId: string) {
    const txUpdate = await client.models.Transaction.update({
        id: transactionId,
        status: 'FAILED'
    });

    if (txUpdate.errors) {
        logger.error('Failed to update Transaction to FAILED', { errors: txUpdate.errors });
    }
}

export async function findPayoutByRef(reference: string) {
    const { data, errors } = await client.models.Payout.list({
        filter: { reference: { eq: reference } }
    });
    if (errors) logger.error('Failed to list payouts', { errors });
    return data?.[0];
}

export async function updatePayoutSuccess(
    payoutId: string,
    agreementId: string,
    milestoneId?: string | null
) {
    const updaterIdentifier = 'FLUTTERWAVE_WEBHOOK';

    // 1. Mark Payout as SUCCESSFUL
    const payoutUpdate = await client.models.Payout.update({
        id: payoutId,
        status: 'SUCCESSFUL'
    });
    if (payoutUpdate.errors) logger.error('Failed to update Payout', { errors: payoutUpdate.errors });

    // 2. If this was a Milestone payout, close the Milestone
    if (milestoneId) {
        const msUpdate = await client.models.Milestone.update({
            id: milestoneId,
            status: 'RELEASED',
            lastUpdatedBy: updaterIdentifier
        });
        if (msUpdate.errors) logger.error('Failed to update Milestone', { errors: msUpdate.errors });

        // NEW: Check if this was the final milestone
        const { data: allMilestones, errors: msErrors } = await client.models.Milestone.list({
            filter: { agreementId: { eq: agreementId } }
        });

        if (!msErrors && allMilestones) {
            // Because DynamoDB is eventually consistent, we check if all OTHER milestones are released
            const allReleased = allMilestones.every(m => m.id === milestoneId || m.status === 'RELEASED');

            if (allReleased) {
                logger.info(`All milestones released. Closing parent agreement: ${agreementId}`);
                const agreeUpdate = await client.models.Agreement.update({
                    id: agreementId,
                    status: 'RELEASED',
                    lastUpdatedBy: updaterIdentifier
                });
                if (agreeUpdate.errors) logger.error('Failed to update Agreement', { errors: agreeUpdate.errors });
            }
        }
    }
    // 3. Otherwise, close the core Agreement directly
    else {
        const agreeUpdate = await client.models.Agreement.update({
            id: agreementId,
            status: 'RELEASED',
            lastUpdatedBy: updaterIdentifier
        });
        if (agreeUpdate.errors) logger.error('Failed to update Agreement', { errors: agreeUpdate.errors });
    }
}

export async function updatePayoutFailed(payoutId: string, failureReason: string) {
    const payoutUpdate = await client.models.Payout.update({
        id: payoutId,
        status: 'FAILED',
        failureReason: failureReason
    });

    if (payoutUpdate.errors) {
        logger.error('Failed to update Payout to FAILED', { errors: payoutUpdate.errors });
    }
}
