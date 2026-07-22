// amplify/functions/process-payouts/handler.ts

import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/process-payouts';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";
import { getAccessToken, getBaseUrl } from "../shared/flutterwave.client";

const logger = new Logger({ serviceName: "process-payouts-sweeper" });
const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();

function generateReference(id: string): string {
    const cleanId = id.replace(/[^a-zA-Z0-9]/g, '');
    const idPart = cleanId.length > 8 ? cleanId.substring(0, 8) : cleanId;
    const timestamp = Date.now().toString();
    const timePart = timestamp.substring(timestamp.length - 8);
    return `${idPart}${timePart}`;
}

async function createAndExecutePayout(
    entityType: 'AGREEMENT' | 'MILESTONE',
    entityId: string,
    agreementId: string,
    amount: number,
    currency: string,
    participants: string[],
    destination: any,
    flwBaseUrl: string,
    flwToken: string,
    businessEnv: string
) {

    let existingPayouts;
    if (entityType === 'MILESTONE') {
        const { data } = await client.models.Payout.list({
            filter: { milestoneId: { eq: entityId } }
        });
        existingPayouts = data;
    } else {
        const { data } = await client.models.Payout.list({
            // Only look for one-time agreement payouts (where milestoneId is technically null/undefined)
            filter: { agreementId: { eq: agreementId }, milestoneId: { attributeExists: false } }
        });
        existingPayouts = data;
    }

    // If a PENDING or SUCCESSFUL payout already exists, DO NOT pay them again!
    const alreadyProcessing = existingPayouts?.some(p => p.status === 'PENDING' || p.status === 'SUCCESSFUL');
    if (alreadyProcessing) {
        logger.info(`Idempotency Check: Payout already exists and is processing for ${entityType} ${entityId}. Skipping.`);
        return true; // Return true so the loop cleanly moves on
    }

    const safeReference = generateReference(entityId);

    const payoutPayload: any = {
        agreementId: agreementId,
        reference: safeReference,
        amount: amount,
        currency: currency,
        status: 'PENDING',
        participants: participants,
        recipientAccountNumber: destination.accountNumber,
        recipientBankCode: destination.bankCode
    };

    if (entityType === 'MILESTONE') {
        payoutPayload.milestoneId = entityId;
    }

    const { data: payout, errors: payoutErrors } = await client.models.Payout.create(payoutPayload);

    if (payoutErrors || !payout) {
        logger.error(`Failed to create Payout record for ${entityType}: ${entityId}`, { errors: payoutErrors });
        return false;
    }

    // Setup Headers conditionally based on environment
    const requestHeaders: any = {
        'Authorization': `Bearer ${flwToken}`,
        'Content-Type': 'application/json'
    };

    // Inject the Scenario Key to force webhooks during Sandbox testing
    if (businessEnv !== 'prod') {
        requestHeaders['X-Scenario-Key'] = 'scenario:successful';
    }

    const response = await fetch(`${flwBaseUrl}/direct-transfers`, {
        method: 'POST',
        headers: requestHeaders,
        body: JSON.stringify({
            action: "instant",
            type: "bank",
            reference: safeReference,
            payment_instruction: {
                source_currency: currency,
                destination_currency: currency,
                amount: { applies_to: "destination_currency", value: amount },
                recipient: {
                    bank: {
                        account_number: destination.accountNumber,
                        code: destination.bankCode
                    }
                }
            }
        })
    });

    const responseData = await response.json();

    if (!response.ok || responseData.status === 'failed') {
        const flwErrorCode = responseData?.error?.code || response.status.toString();
        const flwErrorMessage = responseData?.error?.message || responseData?.message || 'Payout failed to initiate';

        await client.models.Payout.update({
            id: payout.id,
            status: 'FAILED',
            failureReason: `[${flwErrorCode}] ${flwErrorMessage}`
        });

        logger.error(`Flutterwave rejected transfer for ${entityType} ${entityId}: ${flwErrorMessage}`);
        return false;
    }

    await client.models.Payout.update({
        id: payout.id,
        flutterwaveId: responseData.data?.id
    });

    logger.info(`Successfully initiated transfer for ${entityType}: ${entityId}`);
    return true;
}

export const handler = async (_event: any) => {
    logger.info("Starting CRON Sweeper for Escrow Payouts");

    const now = new Date();
    const businessEnv = env.AMPLIFY_DATA_BUSINESS_ENV!;
    const flwBaseUrl = getBaseUrl(businessEnv);

    let flwToken: string | null = null;

    const ensureToken = async () => {
        if (flwToken) return flwToken;

        try {
            logger.info("Payouts detected! Fetching Flutterwave Token...");
            flwToken = await getAccessToken({
                clientId: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_ID! : env.FLW_SANDBOX_CLIENT_ID!,
                clientSecret: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_SECRET! : env.FLW_SANDBOX_CLIENT_SECRET!,
                businessEnv: businessEnv
            });
            return flwToken;
        } catch (error) {
            logger.error("Failed to authenticate with Flutterwave. Aborting sweep.", { error });
            throw error;
        }
    };

    try {
        // ==========================================
        // 1. PROCESS ONE-TIME AGREEMENTS
        // ==========================================
        const { data: pendingAgreements } = await client.models.Agreement.agreementsByStatus({
            status: "PROCESSING_RELEASE",
        });

        for (const agreement of pendingAgreements) {
            try {
                if (!agreement.releaseEligibleAt) continue;
                const eligibleTime = new Date(agreement.releaseEligibleAt);

                if (eligibleTime <= now) {
                    logger.info(`Initiating payout for Agreement: ${agreement.id}`);

                    const token = await ensureToken();

                    const { data: destination, errors: destErrors } = await client.models.PayoutDestination.get({
                        accountNumber: agreement.recipientAccountNumber,
                        bankCode: agreement.recipientBankCode
                    });

                    if (destErrors || !destination) {
                        logger.error("Payout destination is missing.", { agreementId: agreement.id, destErrors });
                        continue;
                    }

                    await createAndExecutePayout(
                        'AGREEMENT',
                        agreement.id,
                        agreement.id,
                        agreement.amount,
                        agreement.currency,
                        agreement.participants as string[],
                        destination,
                        flwBaseUrl,
                        token,
                        businessEnv
                    );
                }
            } catch (error) {
                logger.error(`Unexpected error processing Agreement: ${agreement.id}`, { error });
            }
        }

        // ==========================================
        // 2. PROCESS MILESTONES
        // ==========================================
        const { data: pendingMilestones } = await client.models.Milestone.milestonesByStatus({
            status: "PROCESSING_RELEASE",
        });

        for (const milestone of pendingMilestones) {
            try {
                if (!milestone.releaseEligibleAt) continue;
                const eligibleTime = new Date(milestone.releaseEligibleAt);

                if (eligibleTime <= now) {
                    logger.info(`Initiating payout for Milestone: ${milestone.id}`);

                    const token = await ensureToken();

                    const { data: agreement } = await milestone.agreement();
                    if (!agreement) {
                        logger.error("Parent agreement is missing.", { milestoneId: milestone.id });
                        continue;
                    }

                    // FIX: Direct Query via composite keys from parent agreement
                    const { data: destination, errors: destErrors } = await client.models.PayoutDestination.get({
                        accountNumber: agreement.recipientAccountNumber,
                        bankCode: agreement.recipientBankCode
                    });

                    if (destErrors || !destination) {
                        logger.error("Payout destination is missing.", { milestoneId: milestone.id, destErrors });
                        continue;
                    }

                    await createAndExecutePayout(
                        'MILESTONE',
                        milestone.id,
                        agreement.id,
                        milestone.amount,
                        agreement.currency,
                        milestone.participants as string[],
                        destination,
                        flwBaseUrl,
                        token,
                        businessEnv
                    );
                }
            } catch (error) {
                logger.error(`Unexpected error processing Milestone: ${milestone.id}`, { error });
            }
        }

    } catch (error) {
        logger.error("CRON Sweeper experienced a critical failure", { error });
        return { success: false, reason: "Critical failure" };
    }

    return { success: true };
};
