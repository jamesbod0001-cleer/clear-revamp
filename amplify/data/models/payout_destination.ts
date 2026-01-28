import {a} from "@aws-amplify/backend"

export const PayoutDestination = a.model({
    accountNumber: a.string().required(),
    bankCode: a.string().required(),
    currency: a.string().required(),
    userId: a.id().required(),
    bankName: a.string().required(),
    accountName: a.string().required(),
    isDefault: a.boolean().default(false).authorization(allow => [allow.owner(),]),

    user: a.belongsTo('User', 'userId'),
    agreements: a.hasMany('Agreement', ['recipientAccountNumber', 'recipientBankCode']),
}).identifier(['accountNumber', 'bankCode'])
    .authorization(allow => [
        allow.owner().to(['create', 'read', 'delete']),
        allow.authenticated().to(['read']),
    ]);
