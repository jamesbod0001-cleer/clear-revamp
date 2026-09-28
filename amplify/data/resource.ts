import {type ClientSchema, a, defineData} from '@aws-amplify/backend';
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
import {joinAgreement} from "../functions/join-agreement/resource";
import {logAgreementStatus} from "../functions/log-agreement-status/resource";
import {logMilestoneStatus} from "../functions/log-milestone-status/resource";
import {flutterwaveProxy} from "../functions/flutterwave-proxy/resource";
import {Activity} from "./models/activity";
import {generateAgreementActivity} from "../functions/generate-agreement-activity/resource";
import {DeliveryDetails} from "./custom-types/delivery-details";
import {PhysicalDeliveryContext} from "./custom-types/physical-delivery-context";
import {syncMilestoneToAgreement} from "../functions/sync-milestone-to-agreement/resource";
import {processPayouts} from "../functions/process-payouts/resource";
import {processRefund} from "../functions/process-refund/resource";
import {Payout} from "./models/payout";
import {Refund} from "./models/refund";
import {Dispute} from "./models/dispute";
import {evaluateDeadlines} from "../functions/evaluate-deadlines/resource";
import {logDisputeStatus} from "../functions/log-dispute-status/resource";

const schema = a.schema({
    User,
    Agreement,
    PayoutDestination,
    Milestone,
    Transaction,
    Photo,
    StatusHistory,
    Activity,
    Payout,
    Refund,
    Dispute,
    UserPreview,
    AgreementPreview,
    MilestonePreview,
    DeliveryDetails,
    PhysicalDeliveryContext,
    getServerTime: a
        .query()
        .returns(a.datetime())
        .authorization(allow => [allow.authenticated()])
        .handler(a.handler.custom({ entry: './resolvers/get-server-time.js' })),
    getAgreementPreview: a.query()
        .arguments({ shortCode: a.string().required() })
        .returns(a.ref('AgreementPreview'))
        .authorization(allow => [allow.publicApiKey()])
        .handler(a.handler.function(previewAgreement)),
    joinAgreement: a.mutation()
        .arguments({ shortCode: a.string().required() })
        .returns(a.string()) // Returns the Agreement ID
        .authorization(allow => [allow.authenticated()]) // Only logged-in users!
        .handler(a.handler.function(joinAgreement)),
    flutterwaveProxy: a
        .mutation()
        .arguments({
            method: a.string().required(),
            endpoint: a.string().required(),
            payload: a.string(),
            headers: a.string(),
        })
        .returns(a.string())
        .authorization(allow => [allow.authenticated()])
        .handler(a.handler.function(flutterwaveProxy)),
}).authorization(allow => [allow.resource(logAgreementStatus), allow.resource(logMilestoneStatus),allow.resource(logDisputeStatus), allow.resource(flutterwaveWebhook), allow.resource(previewAgreement), allow.resource(joinAgreement), allow.resource(generateAgreementActivity),allow.resource(syncMilestoneToAgreement),allow.resource(processPayouts), allow.resource(processRefund), allow.resource(evaluateDeadlines)]);

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
    schema,
    authorizationModes: {
        defaultAuthorizationMode: 'userPool',
        apiKeyAuthorizationMode: { expiresInDays: 365 },
    },
});
