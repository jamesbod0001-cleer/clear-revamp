import {a} from "@aws-amplify/backend"

export const Transaction = a.model({
    agreementId: a.id().required(),

    paymentMethodType: a.enum(['CARD', 'USSD', 'BANK_TRANSFER', 'OPAY']),

    // The link to Flutterwave
    reference: a.string().required(), // Your unique ref: AGR_123_TIMESTAMP
    flutterwaveId: a.string().required(),
    // Note: During initial payment setup for 'BANK_TRANSFER', flutterwaveId is set to the Virtual Account ID ('van_...').
    // When the payment succeeds, flutterwaveId is updated to the actual Flutterwave Charge ID ('chg_...')
    // required for refunds, receipts, and dispute resolution.

    // The Money
    amount: a.float().required(),         // agreement.amount + cleerFee
    cleerFee: a.float().default(0.0),     // Cleer platform fee
    gatewayFee: a.float().default(0.0),   // Flutterwave app fee

    currency: a.string().required().default('NGN'),

    // The Status
    status: a.enum(['PENDING', 'SUCCESSFUL', 'FAILED', 'CANCELLED']),

    // Payment Context
    flutterwavePaymentMethodId: a.string(),
    // flutterwavePaymentMethodId will also be null when the paymentMethodType is 'BANK_TRANSFER'

    agreement: a.belongsTo('Agreement', 'agreementId'),
    refunds: a.hasMany('Refund', 'transactionId'),
}).authorization(allow => [
    allow.owner().identityClaim('sub'),
]);
