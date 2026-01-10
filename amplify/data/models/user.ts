import {a} from "@aws-amplify/backend"

export const User = a.model({
    phoneNumber: a.string().required(),
    firstName: a.string().required(),
    lastName: a.string().required(),
    email: a.string(),
    profileImage: a.string(),

}).authorization(allow => [
        allow.owner()
    ])

