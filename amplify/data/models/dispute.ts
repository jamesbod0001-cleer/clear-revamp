import { a } from "@aws-amplify/backend"

export const Dispute = a.model({
    agreementId: a.id().required(),
    milestoneId: a.id(),              // Optional: populated only if disputing a milestone

    raisedById: a.id().required(),    // User ID of the reporter
    reason: a.string().required(),    // Store enum ID string (e.g., 'item_not_received')
    description: a.string().required(), // Detailed text explanation

    evidenceKeys: a.string().array(),  // List of S3 Storage Keys (PDFs, images, docs)

    status: a.enum(['OPEN', 'UNDER_REVIEW', 'RESOLVED', 'DISMISSED']),

    participants: a.string().array(),  // Used for Amplify row-level security
    lastUpdatedBy: a.string(),

    // Relationships
    agreement: a.belongsTo('Agreement', 'agreementId'),
    milestone: a.belongsTo('Milestone', 'milestoneId'),
    raisedBy: a.belongsTo('User', 'raisedById'),

    createdAt: a.datetime(),
    updatedAt: a.datetime(),
}).secondaryIndexes((index) => [
    index("agreementId"),
    index("status")
]).authorization(allow => [
    allow.ownersDefinedIn('participants').identityClaim('sub'),
]);
