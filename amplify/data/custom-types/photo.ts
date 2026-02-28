import {a} from "@aws-amplify/backend"

export const Photo = a.customType({
    key: a.string().required(),
    blurHash: a.string(),
    width: a.integer(),
    height: a.integer(),
    altText: a.string(), // Description for screen readers
});
