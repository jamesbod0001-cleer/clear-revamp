import { generateClient } from 'aws-amplify/data';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";
import { createActivityRecord } from '../shared/activity.utils';
import { formatCurrency } from '../shared/currency.utils';

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
    nextStatus: 'AWAITING_RECIPIENT' | 'FUNDED',
    disbursementType: string,
    gatewayFee?: number | null
) {
    const updaterIdentifier = 'FLUTTERWAVE_WEBHOOK';

    // 1. Mark Transaction as SUCCESSFUL with gateway fee
    const txUpdate = await client.models.Transaction.update({
        id: transactionId,
        status: 'SUCCESSFUL',
        ...(gatewayFee != null ? { gatewayFee } : {})
    });
    if (txUpdate.errors) logger.error('Failed to update Transaction', { errors: txUpdate.errors });

    // 2. Transition Agreement to nextStatus (AWAITING_RECIPIENT or FUNDED)
    const agreeUpdate = await client.models.Agreement.update({
        id: agreementId,
        status: nextStatus,
        lastUpdatedBy: updaterIdentifier
    });
    if (agreeUpdate.errors) logger.error('Failed to update Agreement to nextStatus', { errors: agreeUpdate.errors });

    // 3. If the agreement is now FUNDED (recipient-initiated flow), advance to IN_PROGRESS
    if (nextStatus === 'FUNDED') {
        const progressUpdate = await client.models.Agreement.update({
            id: agreementId,
            status: 'IN_PROGRESS',
            lastUpdatedBy: updaterIdentifier
        });
        if (progressUpdate.errors) logger.error('Failed to update Agreement to IN_PROGRESS', { errors: progressUpdate.errors });

        // Activate Milestone 0 if disbursement is milestone-based
        if (disbursementType === 'MILESTONES') {
            const { data: milestones, errors: msErrors } = await client.models.Milestone.list({
                filter: { agreementId: { eq: agreementId }, order: { eq: 0 } }
            });

            if (msErrors) {
                logger.error('Failed to fetch initial milestone', { errors: msErrors });
            } else if (milestones?.[0]) {
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
    if (txUpdate.errors) logger.error('Failed to update Transaction to FAILED', { errors: txUpdate.errors });
}

export async function updateTransactionCancelled(transactionId: string) {
    const txUpdate = await client.models.Transaction.update({
        id: transactionId,
        status: 'CANCELLED'
    });
    if (txUpdate.errors) logger.error('Failed to update Transaction to CANCELLED', { errors: txUpdate.errors });
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

        const { data: allMilestones, errors: msErrors } = await client.models.Milestone.list({
            filter: { agreementId: { eq: agreementId } }
        });

        if (!msErrors && allMilestones) {
            // Sort by order so we process them in the correct sequence (0, 1, 2...)
            const sortedMilestones = allMilestones.sort((a, b) => (a.order || 0) - (b.order || 0));

            // Check if all OTHER milestones are released
            const allReleased = sortedMilestones.every(m => m.id === milestoneId || m.status === 'RELEASED');

            if (allReleased) {
                logger.info(`All milestones released. Closing parent agreement: ${agreementId}`);
                const agreeUpdate = await client.models.Agreement.update({
                    id: agreementId,
                    status: 'RELEASED',
                    lastUpdatedBy: updaterIdentifier
                });
                if (agreeUpdate.errors) logger.error('Failed to update Agreement', { errors: agreeUpdate.errors });
            } else {
                // ==========================================
                // WAKE UP THE NEXT MILESTONE
                // ==========================================
                // Find the first milestone that is still PENDING
                const nextMilestone = sortedMilestones.find(m => m.status === 'PENDING' && m.id !== milestoneId);

                if (nextMilestone) {
                    const today = new Date().toISOString().split('T')[0];
                    const nextDate = nextMilestone.expectedReleaseDate ? nextMilestone.expectedReleaseDate.split('T')[0] : null;

                    // If it's already overdue when it wakes up, fast-forward it instantly!
                    const targetStatus = (nextDate && nextDate <= today) ? 'READY_FOR_RELEASE' : 'IN_PROGRESS';

                    logger.info(`Waking up next milestone: ${nextMilestone.id} (Order: ${nextMilestone.order}) with status ${targetStatus}`);
                    await client.models.Milestone.update({
                        id: nextMilestone.id,
                        status: targetStatus,
                        lastUpdatedBy: updaterIdentifier
                    });
                }
            }
        }
    } else {
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
    if (payoutUpdate.errors) logger.error('Failed to update Payout to FAILED', { errors: payoutUpdate.errors });
}

export async function findRefundByFlwIdOrChargeId(flutterwaveRefundId?: string, chargeId?: string) {
    if (flutterwaveRefundId) {
        const { data } = await client.models.Refund.list({
            filter: { flutterwaveRefundId: { eq: flutterwaveRefundId } }
        });
        if (data?.[0]) return data[0];
    }
    if (chargeId) {
        const { data } = await client.models.Refund.list({
            filter: { chargeId: { eq: chargeId } }
        });
        if (data?.[0]) return data[0];
    }
    return null;
}

export async function updateRefundSuccess(refundId: string) {
    const { data: refund, errors: refundErr } = await client.models.Refund.get({ id: refundId });
    if (refundErr || !refund) {
        logger.error('Failed to fetch Refund for success update', { errors: refundErr });
        return;
    }

    const refundUpdate = await client.models.Refund.update({
        id: refundId,
        status: 'SUCCESSFUL'
    });
    if (refundUpdate.errors) logger.error('Failed to update Refund to SUCCESSFUL', { errors: refundUpdate.errors });

    try {
        const agreement = await getAgreement(refund.agreementId);
        if (agreement) {
            const senderId = agreement.senderId || agreement.initiatorId;
            const formattedAmount = formatCurrency(refund.amount, refund.currency);
            await createActivityRecord(
                client,
                senderId,
                'PAYMENT',
                'Refund Completed',
                'Your refund has been processed successfully to your account.',
                agreement.id,
                formattedAmount,
                agreement.description
            );
        }
    } catch (err) {
        logger.error('Failed to create Activity record for refund completion', { err });
    }
}

export async function updateRefundFailed(refundId: string, failureReason: string) {
    const refundUpdate = await client.models.Refund.update({
        id: refundId,
        status: 'FAILED',
        failureReason: failureReason
    });
    if (refundUpdate.errors) logger.error('Failed to update Refund to FAILED', { errors: refundUpdate.errors });
}
