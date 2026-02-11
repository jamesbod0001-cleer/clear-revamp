import {a} from "@aws-amplify/backend"

export const Transaction = a.model({
    id: a.id(),
    agreementId: a.string().required(),

    // The link to Flutterwave
    reference: a.string().required(), // Your unique ref: AGR_123_TIMESTAMP
    flutterwaveId: a.string(),        // The 'chg_...' ID

    // The Money
    amount: a.float().required(),
    currency: a.string().required().default('NGN'),

    // The Status
    status: a.enum(['PENDING', 'SUCCESSFUL', 'FAILED', 'CANCELLED']),

    // Payment Context
    paymentMethodId: a.string(),

    agreement: a.belongsTo('Agreement', 'agreementId'),
}).authorization(allow => [
    allow.owner(),
    allow.authenticated().to(['read', 'update']),
]);
