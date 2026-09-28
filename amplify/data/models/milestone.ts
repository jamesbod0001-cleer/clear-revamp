import {a} from "@aws-amplify/backend"

export const Milestone = a.model({
    agreementId: a.id().required(),
    name: a.string().required(),
    amount: a.float().required(),
    order: a.integer().required(),
    expectedReleaseDate: a.date().required(),

    participants: a.string().array(),
    lastUpdatedBy: a.string(),

    releaseEligibleAt: a.datetime(),

    status: a.enum(['PENDING', 'IN_PROGRESS', 'READY_FOR_RELEASE', 'PROCESSING_RELEASE', 'RELEASED', 'DISPUTED']),
    agreement: a.belongsTo('Agreement', 'agreementId'),
    disputes: a.hasMany('Dispute', 'milestoneId'),
    payouts: a.hasMany('Payout', 'milestoneId'),
}).secondaryIndexes((index) => [
    index("status").queryField("milestonesByStatus")
]).authorization(allow => [
    allow.ownersDefinedIn('participants').identityClaim('sub'),
]);
