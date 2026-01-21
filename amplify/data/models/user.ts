import {a} from "@aws-amplify/backend"

export const User = a.model({
    id: a.id().required(),
    phoneNumber: a.string().required(),
    firstName: a.string().required(),
    lastName: a.string().required(),
    email: a.string(),
    profileImage: a.string(),
}).identifier(['id']).authorization(allow => [
        allow.ownerDefinedIn('id'), allow.authenticated().to(['read']),
    ])

