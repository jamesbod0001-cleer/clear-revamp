import { Amplify } from 'aws-amplify';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/flutterwave-webhook';
import type { Handler } from 'aws-lambda';
import { Logger } from "@aws-lambda-powertools/logger";
import * as crypto from 'crypto';
import * as flw from '../shared/flutterwave.client';
import * as db from './db.utils';

const logger = new Logger({ logLevel: "INFO", serviceName: "flutterwave-webhook" });
let isConfigured = false; // Fixes the Amplify configure warning

export const handler: Handler = async (event) => {
    // 1. Configure securely during cold start
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

    // 2. Your original (and correct!) HMAC validation
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

        // Inflow (Collections / Charges)
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
    const transaction = await db.findTransactionByRef(data.tx_ref || data.reference);

    if (!transaction || !transaction.id || !transaction.agreementId || transaction.status === 'SUCCESSFUL') {
        logger.info('Transaction invalid, already processed, or not found. Skipping.');
        return;
    }

    const businessEnv = env.AMPLIFY_DATA_BUSINESS_ENV!;
    const token = await flw.getAccessToken({
        clientId: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_ID! : env.FLW_SANDBOX_CLIENT_ID!,
        clientSecret: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_SECRET! : env.FLW_SANDBOX_CLIENT_SECRET!,
        businessEnv: businessEnv
    });
    const verification = await flw.verifyCharge(data.id, token, businessEnv);

    const flwStatus = verification.data?.status?.toLowerCase();

    if ((flwStatus === 'succeeded' || flwStatus === 'successful') && verification.data.amount >= transaction.amount) {
        logger.info(`Charge verified successfully. Updating DB for Agreement: ${transaction.agreementId}`);
        const agreement = await db.getAgreement(transaction.agreementId);

        const nextStatus = agreement?.initiatorRole === 'SENDER' ? 'AWAITING_RECIPIENT' : 'FUNDED';

        await db.updatePaymentSuccess(
            transaction.id,
            transaction.agreementId,
            nextStatus,
            agreement?.disbursementType ?? 'ONE_TIME'
        );
    } else if (flwStatus === 'failed') {
        logger.warn(`Charge verification returned failed. Marking Transaction as FAILED: ${transaction.id}`);
        await db.updateTransactionFailed(transaction.id);
    }
    // NEW: Handle explicitly VOIDED charges (e.g. Expired Virtual Accounts)
    else if (flwStatus === 'voided') {
        logger.warn(`Charge voided/expired. Marking Transaction as CANCELLED: ${transaction.id}`);
        // Re-use your failed utility, or create a specific updateTransactionCancelled utility
        await db.updateTransactionFailed(transaction.id);
    }
    else {
        logger.error('Charge verification pending or amount mismatch', { verificationData: verification.data });
    }
}

async function processTransfer(data: any) {
    logger.info(`Processing transfer webhook for reference: ${data.reference}`);

    // Find the Payout we created in the Sweeper Lambda
    const payout = await db.findPayoutByRef(data.reference);

    if (!payout || !payout.id || payout.status === 'SUCCESSFUL') {
        logger.info('Payout invalid, already processed, or not found. Skipping.');
        return;
    }

    // Verify status securely against the payload
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
