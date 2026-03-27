import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/preview-agreement';
import type { Schema } from '../../data/resource';

// 1. Initialize the AppSync Client outside the handler for warm starts
const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);

const client = generateClient<Schema>();

// eslint-disable-next-line
export const handler: Schema['getAgreementPreview']['functionHandler'] = async (event) => {
    const { shortCode } = event.arguments;
    let item;
    let queryErrors;

    // --- STEP 1: SAFE DATABASE FETCH ---
    try {
        // Only wrap the actual network call in the try/catch
        const { data: agreements, errors } = await client.models.Agreement.list({
            filter: { shortCode: { eq: shortCode } }
        });

        item = agreements?.[0];
        queryErrors = errors;
    } catch (error) {
        // Catches severe network failures or AWS outages
        console.error("Network/SDK Error:", error);
        throw new Error("Failed to securely connect to database.");
    }

    // Evaluate the GraphQL response outside the try/catch (Fixes the linter warning 🚀)
    if (queryErrors) {
        console.error("GraphQL Errors:", queryErrors);
        throw new Error("Failed to read agreement data.");
    }

    // --- STEP 2: BUSINESS LOGIC GUARD ---
    if (!item) {
        throw new Error("Agreement not found");
    }

    const validStatuses = ['AWAITING_RECIPIENT', 'AWAITING_FUNDING'];
    if (!item.status || !validStatuses.includes(item.status)) {
        throw new Error("This agreement is no longer available.");
    }

    // --- STEP 3: FETCH ASSOCIATED DATA ---
    try {
        async function getSafeUser(userId?: string | null) {
            if (!userId) return null;

            const { data: user } = await client.models.User.get({ id: userId });
            if (!user) return null;

            return {
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
            };
        }

        // Fetch all three parties simultaneously for blazing-fast execution
        const [initiator, sender, recipient] = await Promise.all([
            getSafeUser(item.initiatorId),
            getSafeUser(item.senderId),
            getSafeUser(item.recipientId)
        ]);

        let bankName = null;
        let accountName = null;
        let accountNumber = null;

        // Fetch Payout Destination using the composite identifier
        if (item.recipientAccountNumber && item.recipientBankCode) {
            const { data: payout } = await client.models.PayoutDestination.get({
                accountNumber: item.recipientAccountNumber,
                bankCode: item.recipientBankCode,
            });

            if (payout) {
                bankName = payout.bankName;
                accountName = payout.accountName;
                accountNumber = payout.accountNumber;
            }
        }

        let milestones = null;
        if (item.disbursementType === 'MILESTONES') {
            const { data: milestoneData } = await client.models.Milestone.list({
                filter: { agreementId: { eq: item.id } }
            });

            if (milestoneData && milestoneData.length > 0) {
                milestones = milestoneData.map(ms => ({
                    id: ms.id,
                    name: ms.name,
                    amount: ms.amount,
                    order: ms.order,
                    expectedReleaseDate: ms.expectedReleaseDate,
                }));
            }
        }

        // --- STEP 4: RETURN THE SAFE PAYLOAD ---
        return {
            shortCode: item.shortCode,
            amount: item.amount,
            currency: item.currency,
            category: item.category,
            description: item.description,
            status: item.status,
            initiatorRole: item.initiatorRole,
            disbursementType: item.disbursementType,
            expectedReleaseDate: item.expectedReleaseDate,

            initiator: initiator,
            sender: sender,
            recipient: recipient,

            recipientBankName: bankName,
            recipientAccountName: accountName,
            recipientAccountNumber: accountNumber,

            milestones: milestones,
        };
    } catch (error: any) {
        console.error("Data Enrichment Error:", error);
        throw new Error("Failed to load full agreement details");
    }
};
