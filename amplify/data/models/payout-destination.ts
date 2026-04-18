import {a} from "@aws-amplify/backend"

export const PayoutDestination = a.model({
    accountNumber: a.string().required(),
    bankCode: a.string().required(),
    currency: a.string().required(),
    userId: a.id(),
    bankName: a.string().required(),
    accountName: a.string().required(),

    user: a.belongsTo('User', 'userId'),
    agreements: a.hasMany('Agreement', ['recipientAccountNumber', 'recipientBankCode']),
}).identifier(['accountNumber', 'bankCode'])
    .authorization(allow => [
        allow.authenticated().to(['create', 'read', 'delete']),

    ]);
