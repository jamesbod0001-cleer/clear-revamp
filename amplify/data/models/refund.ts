import { a } from "@aws-amplify/backend";

export const Refund = a.model({
    agreementId: a.id().required(),
    transactionId: a.id().required(),

    // Flutterwave Identifiers
    chargeId: a.string().required(),            // The 'chg_...' ID that was refunded
    flutterwaveRefundId: a.string(),            // The 'rfd_...' ID returned by Flutterwave

    // Financial Metrics
    amount: a.float().required(),
    currency: a.string().required().default('NGN'),
    reason: a.string(),

    // Lifecycle Status ('PENDING', 'SUCCESSFUL', 'FAILED')
    status: a.enum(['PENDING', 'SUCCESSFUL', 'FAILED']),
    failureReason: a.string(),

    // Audit Metadata
    participants: a.string().array(),

    // Relations
    agreement: a.belongsTo('Agreement', 'agreementId'),
    transaction: a.belongsTo('Transaction', 'transactionId'),
}).authorization(allow => [
    allow.ownersDefinedIn('participants').identityClaim('sub'),
]);
