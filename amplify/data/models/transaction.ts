import {a} from "@aws-amplify/backend"

export const Transaction = a.model({
    agreementId: a.id().required(),

    paymentMethodType: a.enum(['CARD', 'USSD', 'BANK_TRANSFER', 'OPAY']),

    // The link to Flutterwave
    reference: a.string().required(), // Your unique ref: AGR_123_TIMESTAMP
    flutterwaveId: a.string().required(),        // The 'chg_...' ID
    // Note: When paymentMethodType is 'BANK_TRANSFER', flutterwaveId will be the dynamic virtual account id. Otherwise, it is the charge id as usual.

    // The Money
    amount: a.float().required(),
    currency: a.string().required().default('NGN'),

    // The Status
    status: a.enum(['PENDING', 'SUCCESSFUL', 'FAILED', 'CANCELLED']),

    // Payment Context
    flutterwavePaymentMethodId: a.string(),
    // flutterwavePaymentMethodId will also be null when the paymentMethodType is 'BANK_TRANSFER'

    agreement: a.belongsTo('Agreement', 'agreementId'),
}).authorization(allow => [
    allow.owner().identityClaim('sub'),
]);
