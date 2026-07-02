import { a } from "@aws-amplify/backend"

export const StatusHistory = a.model({
    entityId: a.id().required(),
    entityType: a.string().required(), // 'AGREEMENT' or 'MILESTONE'

    context: a.string().required(), // 'CORE_STATUS' or 'DELIVERY_STATUS'

    oldStatus: a.string(),
    newStatus: a.string().required(),
    changedBy: a.string(),

}).secondaryIndexes((index) => [
    // Simplified index without sort keys
    index("entityId").queryField("listByEntity")
]).authorization(allow => [
    allow.authenticated().to(['read', 'create'])
]);
