import {a} from "@aws-amplify/backend"

export const StatusHistory = a.model({
    agreementId: a.id(),
    milestoneId: a.id(),

    oldStatus: a.string(),
    newStatus: a.string().required(),
    changedBy: a.string(),

    // Relationships back to parents
    agreement: a.belongsTo('Agreement', 'agreementId'),
    milestone: a.belongsTo('Milestone', 'milestoneId'),
}).authorization(allow => [
    allow.authenticated().to(['read'])
]);
