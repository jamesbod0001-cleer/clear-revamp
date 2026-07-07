import {a} from "@aws-amplify/backend"

export const DeliveryDetails = a.customType({
    driverPhoneNumber: a.string().required(),
    additionalDetails: a.string(),
    photos: a.ref('Photo').array(),
    arrangedBy: a.enum(['VENDOR', 'BUYER']),
});
