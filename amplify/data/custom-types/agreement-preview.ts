import {a} from "@aws-amplify/backend"

export const AgreementPreview = a.customType({
    shortCode: a.string().required(),
    amount: a.float().required(),
    currency: a.string().required(),
    description: a.string().required(),
    category: a.string().required(),
    status: a.string(),
    initiatorRole: a.string(),
    disbursementType: a.string(),
    expectedReleaseDate: a.date(),

    // 2. Use the references! Much cleaner.
    initiator: a.ref('UserPreview'),
    sender: a.ref('UserPreview'),
    recipient: a.ref('UserPreview'),

    recipientBankName: a.string(),
    recipientAccountName: a.string(),
    recipientAccountNumber: a.string(),

    milestones: a.ref('MilestonePreview').array(),
});
