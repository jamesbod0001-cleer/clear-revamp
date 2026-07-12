import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { storage } from "./storage/resource";

import { flutterwaveWebhook } from "./functions/flutterwave-webhook/resource";

// CDK imports for DynamoDB Streams
import { DynamoEventSource } from 'aws-cdk-lib/aws-lambda-event-sources';
import { StartingPosition, FilterCriteria, FilterRule } from 'aws-cdk-lib/aws-lambda';
import { StreamViewType } from 'aws-cdk-lib/aws-dynamodb';

import { PolicyStatement } from 'aws-cdk-lib/aws-iam';

import { FunctionUrlAuthType, HttpMethod } from 'aws-cdk-lib/aws-lambda';
import { previewAgreement } from "./functions/preview-agreement/resource";
import { logAgreementStatus } from "./functions/log-agreement-status/resource";
import { logMilestoneStatus } from "./functions/log-milestone-status/resource";
import { generateAgreementActivity } from "./functions/generate-agreement-activity/resource";
import { dispatchActivityNotification } from "./functions/dispatch-activity-notification/resource";
import {syncMilestoneToAgreement} from "./functions/sync-milestone-to-agreement/resource";

const backend = defineBackend({
    auth,
    data,
    storage,
    logAgreementStatus,
    logMilestoneStatus,
    flutterwaveWebhook,
    previewAgreement,
    generateAgreementActivity,
    dispatchActivityNotification,
    syncMilestoneToAgreement,
});

// --- Auth Overrides ---
const { cfnUserPool } = backend.auth.resources.cfnResources;
cfnUserPool.policies = {
    passwordPolicy: {
        minimumLength: 8,
        requireLowercase: true,
        requireNumbers: true,
        requireSymbols: false,
        requireUppercase: true,
    },
};
cfnUserPool.usernameAttributes = [];
cfnUserPool.aliasAttributes = ['phone_number','email'];

// --- Webhook Configuration ---
const webhookLambda = backend.flutterwaveWebhook.resources.lambda;
webhookLambda.addFunctionUrl({
    authType: FunctionUrlAuthType.NONE,
    cors: {
        allowedOrigins: ['*'],
        allowedMethods: [HttpMethod.POST],
        allowedHeaders: ['*'],
    },
});

// --- DynamoDB Stream Configuration (Status Tracker) ---
const { cfnResources } = backend.data.resources;
cfnResources.amplifyDynamoDbTables['Agreement'].streamSpecification = {
    streamViewType: StreamViewType.NEW_AND_OLD_IMAGES,
};
cfnResources.amplifyDynamoDbTables['Milestone'].streamSpecification = {
    streamViewType: StreamViewType.NEW_AND_OLD_IMAGES,
};

const agreementTable = backend.data.resources.tables['Agreement'];
const milestoneTable = backend.data.resources.tables['Milestone'];

// Simplified filter: Just wake up on any modification.
// The Lambdas will diff the old and new images to see thr actual change.
const anyModificationFilter = FilterCriteria.filter({
    eventName: FilterRule.or('INSERT', 'MODIFY')
});

backend.logAgreementStatus.resources.lambda.addEventSource(
    new DynamoEventSource(agreementTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [anyModificationFilter],
    })
);

backend.logMilestoneStatus.resources.lambda.addEventSource(
    new DynamoEventSource(milestoneTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [anyModificationFilter],
    })
);


backend.generateAgreementActivity.resources.lambda.addEventSource(
    new DynamoEventSource(agreementTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [anyModificationFilter],
    })
);

backend.syncMilestoneToAgreement.resources.lambda.addEventSource(
    new DynamoEventSource(milestoneTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [anyModificationFilter],
    })
);


// --- Activity Notification Dispatcher ---
const activityTable = backend.data.resources.tables['Activity'];
const userTable = backend.data.resources.tables['User'];

// 1. Maintain stream configuration active
cfnResources.amplifyDynamoDbTables['Activity'].streamSpecification = {
    streamViewType: StreamViewType.NEW_IMAGE,
};

// 2. Grant permissions and inject table name safely
userTable.grantReadData(backend.dispatchActivityNotification.resources.lambda);
(backend.dispatchActivityNotification.resources.lambda as any).addEnvironment('USER_TABLE_NAME', userTable.tableName);

backend.dispatchActivityNotification.resources.lambda.addToRolePolicy(new PolicyStatement({
    actions: ['mobiletargeting:SendMessages'],
    resources: [`arn:aws:mobiletargeting:eu-west-1:682718097244:apps/eb6ecf886702464f8200538bee04719b/*`]
}));

// 3. Connect standard event trigger mapping onto the live stream
backend.dispatchActivityNotification.resources.lambda.addEventSource(
    new DynamoEventSource(activityTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [
            FilterCriteria.filter({
                eventName: ['INSERT']
            })
        ],
    })
);


// --- Push Notifications Output Mapping ---
backend.addOutput({
    notifications: {
        amazon_pinpoint_app_id: "eb6ecf886702464f8200538bee04719b",
        aws_region: "eu-west-1",
        channels: ["FCM", "APNS"],
    },
});

// --- Push Notification IAM Permissions ---
const pinpointStatement = new PolicyStatement({
    actions: [
        "mobiletargeting:UpdateEndpoint",
        "mobiletargeting:PutEvents"
    ],
    resources: [
        "arn:aws:mobiletargeting:eu-west-1:682718097244:apps/eb6ecf886702464f8200538bee04719b",
        "arn:aws:mobiletargeting:eu-west-1:682718097244:apps/eb6ecf886702464f8200538bee04719b/*"
    ]
});

backend.auth.resources.authenticatedUserIamRole.addToPrincipalPolicy(pinpointStatement);
backend.auth.resources.unauthenticatedUserIamRole.addToPrincipalPolicy(pinpointStatement);
