import {a} from "@aws-amplify/backend"

export const UserPreview = a.customType({
    id: a.string().required(),
    firstName: a.string().required(),
    lastName: a.string().required(),
});
