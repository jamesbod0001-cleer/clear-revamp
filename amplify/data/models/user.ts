import {a} from "@aws-amplify/backend"

export const User = a.model({
    id: a.id().required(),
    identityId: a.string().required(),
    phoneNumber: a.string().required(),
    firstName: a.string().required(),
    lastName: a.string().required(),
    email: a.string(),
    isEmailVerified: a.boolean(),
    profilePicture: a.ref('Photo'),

    // Flutterwave
    flutterwaveCustomerId: a.string().required(),
    flutterwavePaymentMethodIds: a.string().array(),

    deviceToken: a.string(),

    initiatedAgreements: a.hasMany('Agreement', 'initiatorId'), // Agreements this user physically created
    sentAgreements: a.hasMany('Agreement', 'senderId'), // Agreements where this user is the one paying
    receivedAgreements: a.hasMany('Agreement', 'recipientId'), // Agreements where this user is the one getting paid
    payoutDestinations: a.hasMany('PayoutDestination', 'userId'),
    disputes: a.hasMany('Dispute', 'raisedById'),
}).identifier(['id']).authorization(allow => [
    allow.ownerDefinedIn('id').identityClaim('sub'),
])

