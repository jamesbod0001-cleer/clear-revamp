import { DynamoDBStreamHandler } from 'aws-lambda';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/process-refund';
import type { Schema } from '../../data/resource';
import { Logger } from "@aws-lambda-powertools/logger";
import { getAccessToken, createRefund, listChargesByVirtualAccount } from "../shared/flutterwave.client";
import { createActivityRecord } from '../shared/activity.utils';
import { formatCurrency } from '../shared/currency.utils';

const logger = new Logger({ serviceName: "process-refund" });
const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);
const client = generateClient<Schema>();

export const handler: DynamoDBStreamHandler = async (event) => {
    logger.info("Processing DynamoDB stream event for Refunds");

    const businessEnv = env.AMPLIFY_DATA_BUSINESS_ENV!;
    let flwToken: string | null = null;

    const ensureToken = async () => {
        if (flwToken) return flwToken;
        flwToken = await getAccessToken({
            clientId: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_ID! : env.FLW_SANDBOX_CLIENT_ID!,
            clientSecret: businessEnv === 'prod' ? env.FLW_PROD_CLIENT_SECRET! : env.FLW_SANDBOX_CLIENT_SECRET!,
            businessEnv: businessEnv
        });
        return flwToken;
    };

    for (const record of event.Records) {
        try {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                const newItem = unmarshall(record.dynamodb?.NewImage as any);
                const oldItem = record.dynamodb?.OldImage ? unmarshall(record.dynamodb?.OldImage as any) : null;

                const newStatus = newItem.status;
                const oldStatus = oldItem?.status;

                // Check if status transitioned to CANCELLED or REJECTED
                if ((newStatus === 'CANCELLED' || newStatus === 'REJECTED') && newStatus !== oldStatus) {
                    const agreementId = newItem.id;
                    const initiatorRole = newItem.initiatorRole;

                    // Skip if the agreement was cancelled/rejected before being funded
                    const wasFunded = oldStatus && oldStatus !== 'DRAFT' && oldStatus !== 'AWAITING_FUNDING';
                    if (!wasFunded) {
                        logger.info(`Agreement ${agreementId} was cancelled/rejected before funding (oldStatus: ${oldStatus}). Skipping refund.`);
                        continue;
                    }

                    // Only agreements where the SENDER paid funds into escrow require a refund
                    if (initiatorRole !== 'SENDER') {
                        logger.info(`Agreement ${agreementId} was not funded by sender (initiatorRole: ${initiatorRole}). Skipping refund.`);
                        continue;
                    }

                    // Fetch successful transaction for this agreement
                    const { data: transactions, errors: txErrors } = await client.models.Transaction.list({
                        filter: { agreementId: { eq: agreementId }, status: { eq: 'SUCCESSFUL' } }
                    });

                    if (txErrors || !transactions || transactions.length === 0) {
                        logger.warn(`No successful transaction found for agreement ${agreementId}. Skipping refund.`);
                        continue;
                    }

                    const successfulTx = transactions[0];
                    let chargeId = successfulTx.flutterwaveId;

                    if (!chargeId) {
                        logger.error(`Transaction ${successfulTx.id} missing flutterwaveId charge ID.`);
                        continue;
                    }

                    // Idempotency Check: Verify if a Refund record already exists for this agreement
                    const { data: existingRefunds } = await client.models.Refund.list({
                        filter: { agreementId: { eq: agreementId } }
                    });

                    const alreadyProcessing = existingRefunds?.some(r => r.status === 'PENDING' || r.status === 'SUCCESSFUL');
                    if (alreadyProcessing) {
                        logger.info(`Refund already processing or completed for agreement ${agreementId}. Skipping.`);
                        continue;
                    }

                    const token = await ensureToken();

                    /**
                     * Fallback Safety Net:
                     * If flutterwaveId is still a Virtual Account ID (van_...), query Flutterwave
                     * for charges linked to this virtual account to resolve the actual Charge ID (chg_...).
                     */
                    if (chargeId.startsWith('van_')) {
                        logger.info(`flutterwaveId ${chargeId} is a Virtual Account ID. Resolving associated Charge ID...`);
                        try {
                            const vanCharges = await listChargesByVirtualAccount(chargeId, token, businessEnv);
                            if (vanCharges && vanCharges.length > 0) {
                                const resolvedCharge = vanCharges.find((c: any) => c.status === 'successful' || c.status === 'succeeded') || vanCharges[0];
                                if (resolvedCharge?.id) {
                                    chargeId = resolvedCharge.id;
                                    logger.info(`Successfully resolved Virtual Account ID ${successfulTx.flutterwaveId} to Charge ID: ${chargeId}`);
                                }
                            }
                        } catch (err) {
                            logger.error(`Failed to resolve Virtual Account ID ${chargeId} to Charge ID`, { err });
                        }
                    }

                    logger.info(`Initiating Flutterwave refund for agreement ${agreementId}, charge: ${chargeId}`);

                    const refundRes = await createRefund({
                        chargeId: chargeId,
                        amount: newItem.amount,
                        reason: 'requested_by_customer',
                        accessToken: token,
                        businessEnv: businessEnv
                    });

                    const flwStatus = refundRes.data?.status?.toLowerCase();
                    const initialStatus = (flwStatus === 'succeeded' || flwStatus === 'completed') ? 'SUCCESSFUL' : 'PENDING';

                    // Store Refund Record
                    await client.models.Refund.create({
                        agreementId: agreementId,
                        transactionId: successfulTx.id,
                        chargeId: chargeId,
                        flutterwaveRefundId: refundRes.data?.id,
                        amount: newItem.amount,
                        currency: newItem.currency,
                        reason: `Agreement ${newStatus}`,
                        status: initialStatus,
                        participants: newItem.participants
                    });

                    logger.info(`Successfully created Refund record for agreement ${agreementId}`);

                    if (initialStatus === 'SUCCESSFUL') {
                        const senderId = newItem.senderId || newItem.initiatorId;
                        const formattedAmount = formatCurrency(newItem.amount, newItem.currency);
                        await createActivityRecord(
                            client,
                            senderId,
                            'PAYMENT',
                            'Refund Completed',
                            'Your refund has been processed successfully to your account.',
                            agreementId,
                            formattedAmount,
                            newItem.description
                        );
                    }
                }
            }
        } catch (error) {
            logger.error(`Error processing stream record for refund`, { error });
        }
    }
};
