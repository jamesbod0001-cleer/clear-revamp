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
