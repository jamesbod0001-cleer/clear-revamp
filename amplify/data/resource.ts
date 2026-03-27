import {type ClientSchema, a, defineData} from '@aws-amplify/backend';
import {statusTracker} from '../functions/status-tracker/resource';
import {flutterwaveWebhook} from '../functions/flutterwave-webhook/resource';
import {User} from "./models/user";
import {Agreement} from "./models/agreement";
import {PayoutDestination} from "./models/payout-destination";
import {Transaction} from "./models/transaction";
import {Milestone} from "./models/milestone";
import {StatusHistory} from "./models/status-history";
import {Photo} from "./custom-types/photo";
import {previewAgreement} from "../functions/preview-agreement/resource";
import {UserPreview} from "./custom-types/user-preview";
import {AgreementPreview} from "./custom-types/agreement-preview";
import {MilestonePreview} from "./custom-types/milestone-preview";

const schema = a.schema({
    User,
    Agreement,
    PayoutDestination,
    Milestone,
    Transaction,
    Photo,
    StatusHistory,
    UserPreview,
    AgreementPreview,
    MilestonePreview,
    getServerTime: a
        .query()
        .returns(a.datetime())
        .authorization(allow => [allow.authenticated()])
        .handler(a.handler.custom({ entry: './resolvers/get-server-time.js' })),
    getAgreementPreview: a.query()
        .arguments({ shortCode: a.string().required() })
        .returns(a.ref('AgreementPreview'))
        .authorization(allow => [allow.publicApiKey()])
        .handler(a.handler.function(previewAgreement))
}).authorization(allow => [allow.resource(statusTracker), allow.resource(flutterwaveWebhook), allow.resource(previewAgreement)]);

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
    schema,
    authorizationModes: {
        defaultAuthorizationMode: 'userPool',
        apiKeyAuthorizationMode: { expiresInDays: 365 },
    },
});
