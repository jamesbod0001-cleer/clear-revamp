import { a } from "@aws-amplify/backend";

export const Payout = a.model({
    agreementId: a.id().required(),
    milestoneId: a.id(), // Optional: Null if it's a one-time agreement

    recipientAccountNumber: a.string().required(),
    recipientBankCode: a.string().required(),

    // The Unique Reference generated for Flutterwave Outflow
    reference: a.string().required(), // e.g. PAY_UUID_TIMESTAMP
    flutterwaveId: a.string(),        // The 'trf_...' ID (updated asynchronously)

    // Financial Matrix
    amount: a.float().required(),
    currency: a.string().required().default('NGN'),
    fee: a.float(), // Track what Flutterwave charges you for the payout execution

    // Lifecycle Status
    status: a.enum(['PENDING', 'SUCCESSFUL', 'FAILED']),

    // Additional Audit Metadata
    failureReason: a.string(),
    narration: a.string(),

    // Shared context authorization array from parent agreement
    participants: a.string().array(),

    // Relations
    agreement: a.belongsTo('Agreement', 'agreementId'),
    milestone: a.belongsTo('Milestone', 'milestoneId'),
    payoutDestination: a.belongsTo('PayoutDestination', ['recipientAccountNumber', 'recipientBankCode']),
}).authorization(allow => [
    // Allow both the sender and recipient to track the history of the payout
    allow.ownersDefinedIn('participants').identityClaim('sub'),
]);
