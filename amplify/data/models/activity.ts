import {a} from "@aws-amplify/backend"

export const Activity = a.model({
    userId: a.id().required(),
    type: a.enum(['AGREEMENT', 'PAYMENT', 'DELIVERY']),
    heading: a.string().required(),
    supportingText: a.string().required(),
    formattedAmount: a.string(),
    description: a.string(),
    isRead: a.boolean().default(false),
    entityId: a.string(),
    createdAt: a.datetime(),
}).secondaryIndexes((index) => [
    index("userId")
        .sortKeys(["createdAt"])
        .queryField("listActivitiesByUser")
]).authorization(allow => [
    allow.ownerDefinedIn('userId').to(['read', 'update']).identityClaim('sub'),
]);
