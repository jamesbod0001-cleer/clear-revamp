import {type ClientSchema, a, defineData} from '@aws-amplify/backend';
import {statusTracker} from '../functions/status-tracker/resource';
import {flutterwaveWebhook} from '../functions/flutterwave-webhook/resource'; // 1. Import it
import {User} from "./models/user";
import {Agreement} from "./models/agreement";
import {PayoutDestination} from "./models/payout-destination";
import {Transaction} from "./models/transaction";
import {Milestone} from "./models/milestone";
import {StatusHistory} from "./models/status-history";
import {Photo} from "./custom-types/photo";

const schema = a.schema({
    User,
    Agreement,
    PayoutDestination,
    Milestone,
    Transaction,
    Photo,
    StatusHistory,
    getServerTime: a
        .query()
        .returns(a.datetime())
        .authorization(allow => [allow.authenticated()])
        .handler(a.handler.custom({ entry: './resolvers/get-server-time.js' })),
}).authorization(allow => [allow.resource(statusTracker), allow.resource(flutterwaveWebhook)]);

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
    schema,
    authorizationModes: {
        defaultAuthorizationMode: 'userPool',
    },
});
