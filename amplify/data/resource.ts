import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import {User} from "./models/user";
import {Agreement} from "./models/agreement";
import {PayoutDestination} from "./models/payout_destination";
import {Transaction} from "./models/transaction";

const schema = a.schema({
    User,
    Agreement,
    PayoutDestination,
    Transaction,
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
    schema,
    authorizationModes: {
        defaultAuthorizationMode: 'userPool',
    },
});
