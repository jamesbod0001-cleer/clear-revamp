import {a} from "@aws-amplify/backend"

export const PhysicalDeliveryContext = a.customType({
    status: a.enum([
        'AWAITING_PACKAGING',
        'AWAITING_DISPATCH',
        'AWAITING_BUYER_ACKNOWLEDGEMENT',
        'IN_TRANSIT'
    ]),
    packagingPhotos: a.ref('Photo').array(),
    deliveryDetails: a.ref('DeliveryDetails'),
});
