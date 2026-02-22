import {a} from "@aws-amplify/backend"

export const Milestone = a.model({
    agreementId: a.id().required(),
    name: a.string().required(),
    amount: a.float().required(),
    order: a.integer().required(),
    expectedReleaseDate: a.date().required(),
    status: a.enum(['PENDING', 'IN_PROGRESS', 'COMPLETED', 'PENDING_RELEASE', 'RELEASED', 'DISPUTED']),
    agreement: a.belongsTo('Agreement', 'agreementId'),
}).authorization(allow => [
    allow.owner(), // The initiator is the owner
    allow.authenticated().to(['read']),
]);
