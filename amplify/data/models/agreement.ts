import {a} from "@aws-amplify/backend"

export const Agreement = a.model({
    amount: a.float().required(),
    currency: a.string().required(),
    disbursementType: a.enum(['ONE_TIME', 'MILESTONES']),
    category: a.string().required(),
    expectedReleaseDate: a.date().required(),
    description: a.string().required(),

    // The person who physically clicked "Create Agreement"
    initiatorId: a.id().required(),
    // Tells us if the initiator is the one PAYING or GETTING PAID
    initiatorRole: a.enum(['SENDER', 'RECIPIENT']),

    // Participants
    senderId: a.id(),    // The person providing the money
    recipientId: a.id(), // The person receiving the money

    // Payout Anchor (Always required because funds must have a destination)
    recipientAccountNumber: a.string().required(),
    recipientBankCode: a.string().required(),

    status: a.enum(['DRAFT', 'AWAITING_RECIPIENT', 'AWAITING_FUNDING', 'FUNDED', 'IN_PROGRESS']),

    // Relationships
    milestones: a.hasMany('Milestone', 'agreementId'),
    initiator: a.belongsTo('User', 'initiatorId'),
    sender: a.belongsTo('User', 'senderId'),
    recipient: a.belongsTo('User', 'recipientId'),
    payoutDestination: a.belongsTo('PayoutDestination', ['recipientAccountNumber', 'recipientBankCode']),
    transactions: a.hasMany('Transaction', 'agreementId'),
}).authorization(allow => [
    allow.owner(), // The initiator is the owner
    allow.authenticated().to(['read']),
]);
