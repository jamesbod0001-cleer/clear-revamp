import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import {User} from "./models/user";
import {Agreement} from "./models/agreement";
import {PayoutDestination} from "./models/payout-destination";
import {Transaction} from "./models/transaction";
import {Milestone} from "./models/milestone";
import {Photo} from "./custom-types/photo";

const schema = a.schema({
    User,
    Agreement,
    PayoutDestination,
    Milestone,
    Transaction,
    Photo,
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
    schema,
    authorizationModes: {
        defaultAuthorizationMode: 'userPool',
    },
});
