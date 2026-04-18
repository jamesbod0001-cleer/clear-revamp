import {a} from "@aws-amplify/backend"

export const MilestonePreview = a.customType({
    id: a.string().required(),
    name: a.string().required(),
    amount: a.float().required(),
    order: a.integer().required(),
    expectedReleaseDate: a.date().required(),
});
