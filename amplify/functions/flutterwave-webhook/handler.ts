import { Amplify } from 'aws-amplify';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/flutterwave-webhook';
import type { Handler } from 'aws-lambda';
import { Logger } from "@aws-lambda-powertools/logger";
import * as crypto from 'crypto';
import * as flw from '../shared/flutterwave.client';
import * as db from './db.utils';

const logger = new Logger({ logLevel: "INFO", serviceName: "flutterwave-webhook" });
let isConfigured = false;

export const handler: Handler = async (event) => {
    if (!isConfigured) {
        const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
        Amplify.configure(resourceConfig, libraryOptions);
        isConfigured = true;
    }

    logger.info("--- WEBHOOK INVOCATION START ---");

    const rawBody = event.isBase64Encoded
        ? Buffer.from(event.body, 'base64').toString()
        : event.body;

    const signature = event.headers['flutterwave-signature'] || event.headers['verif-hash'];
    const secretHash = env.FLW_SECRET_HASH;

    if (!signature || !secretHash) {
        logger.error('Missing signature or secret hash');
        return { statusCode: 401 };
    }

    const expectedSignature = crypto
        .createHmac('sha256', secretHash)
        .update(rawBody)
        .digest('base64');

    if (signature !== expectedSignature) {
        logger.error('Unauthorized. Signature match failed.', {
            received: signature,
            expected: expectedSignature
        });
        return { statusCode: 401 };
    }

    try {
        const payload = JSON.parse(rawBody);
        logger.info(`Processing event type: ${payload.event || payload.type}`);

        const eventType = payload.type || payload.event;

        // Inflow (Collections / Charges / Virtual Accounts)
        if (eventType === 'charge.completed') {
            await processCharge(payload.data);
        }
        // Outflow (Payouts / Transfers)
        else if (eventType === 'transfer.disburse') {
            await processTransfer(payload.data);
        }

        return { statusCode: 200, body: 'Webhook received' };
    } catch (error) {
        logger.error('Webhook processing failed', { error });
        return { statusCode: 500 };
    }
};

async function processCharge(data: any) {
    const reference = data.tx_ref || data.reference;

    // Look up transaction by reference (works for Card, USSD, OPay, and Bank Transfers)
    const transaction = await db.findTransactionByRef(reference);

    if (!transaction || !transaction.id || !transaction.agreementId || transaction.status === 'SUCCESSFUL') {
        logger.info('Transaction invalid, already processed, or not found. Skipping.');
        return;
    }

    // 2. Query Flutterwave API to verify charge authenticity and exact amount
    const businessEnv = env.AMPLIFY_DATA_BUSINESS_ENV!;
    const token = await flw.getAccessToken({
        clientId: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_ID! : env.FLW_SANDBOX_CLIENT_ID!,
        clientSecret: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_SECRET! : env.FLW_SANDBOX_CLIENT_SECRET!,
        businessEnv: businessEnv
    });
    const verification = await flw.verifyCharge(data.id, token, businessEnv);

    const flwStatus = verification.data?.status?.toLowerCase();

    // 3. Evaluate verification status against Transaction amount (Agreement Amount + Cleer Fee)
    if ((flwStatus === 'succeeded' || flwStatus === 'successful') && verification.data.amount >= transaction.amount) {
        logger.info(`Charge verified successfully. Updating DB for Agreement: ${transaction.agreementId}`);
        const agreement = await db.getAgreement(transaction.agreementId);

        const nextStatus = agreement?.initiatorRole === 'SENDER' ? 'AWAITING_RECIPIENT' : 'FUNDED';

        // Extract actual app fee from Flutterwave fees breakdown if available
        const feesList: Array<{ type: string; amount: number }> = verification.data.fees || [];
        const appFee = (feesList.find(f => f.type === 'app')?.amount ?? transaction.gatewayFee) ?? undefined;

        await db.updatePaymentSuccess(
            transaction.id,
            transaction.agreementId,
            nextStatus,
            agreement?.disbursementType ?? 'ONE_TIME',
            appFee
        );

    } else if (flwStatus === 'failed') {
        logger.warn(`Charge verification returned failed. Marking Transaction as FAILED: ${transaction.id}`);
        await db.updateTransactionFailed(transaction.id);
    } else if (flwStatus === 'voided') {
        logger.warn(`Charge voided/expired. Marking Transaction as CANCELLED: ${transaction.id}`);
        await db.updateTransactionCancelled(transaction.id);
    } else {
        logger.error('Charge verification pending or amount mismatch', {
            expectedAmount: transaction.amount,
            receivedAmount: verification.data?.amount,
            status: flwStatus
        });
    }
}

async function processTransfer(data: any) {
    logger.info(`Processing transfer webhook for reference: ${data.reference}`);

    const payout = await db.findPayoutByRef(data.reference);

    if (!payout || !payout.id || payout.status === 'SUCCESSFUL') {
        logger.info('Payout invalid, already processed, or not found. Skipping.');
        return;
    }

    if (data.status === 'SUCCESSFUL') {
        logger.info(`Transfer successful. Finalizing Payout: ${payout.id}`);
        await db.updatePayoutSuccess(
            payout.id,
            payout.agreementId,
            payout.milestoneId
        );
    } else if (data.status === 'FAILED') {
        logger.error(`Transfer failed by banking partner.`, { data });
        const failureReason = 'Transfer failed at the provider or bank level.';
        await db.updatePayoutFailed(payout.id, failureReason);
    }
}
