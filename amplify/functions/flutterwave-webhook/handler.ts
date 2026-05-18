import { Amplify } from 'aws-amplify';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/flutterwave-webhook';
import type { Handler } from 'aws-lambda';
import { Logger } from "@aws-lambda-powertools/logger";
import * as crypto from 'crypto';
import * as flw from './flutterwave.client';
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

        if (payload.type === 'charge.completed' || payload.event === 'charge.completed') {
            await processCharge(payload.data);
        }

        return { statusCode: 200, body: 'Webhook received' };
    } catch (error) {
        logger.error('Webhook processing failed', { error });
        return { statusCode: 500 };
    }
};

async function processCharge(data: any) {
    // ... keep your processCharge logic exactly the same as the previous step ...
    const transaction = await db.findTransactionByRef(data.tx_ref || data.reference);

    if (!transaction || !transaction.id || !transaction.agreementId || transaction.status === 'SUCCESSFUL') {
        logger.info('Transaction invalid, already processed, or not found. Skipping.');
        return;
    }

    const token = await flw.getAccessToken();
    const verification = await flw.verifyCharge(data.id, token);

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
    } else {
        logger.error('Charge verification failed or amount mismatch', { verificationData: verification.data });
    }
}
