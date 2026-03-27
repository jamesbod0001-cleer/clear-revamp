// amplify/backend.ts
import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { storage } from "./storage/resource";
import { statusTracker } from "./functions/status-tracker/resource";

// 1. Import the webhook resource
import { flutterwaveWebhook } from "./functions/flutterwave-webhook/resource";

// CDK imports for DynamoDB Streams
import { DynamoEventSource } from 'aws-cdk-lib/aws-lambda-event-sources';
import { StartingPosition } from 'aws-cdk-lib/aws-lambda';
import { StreamViewType } from 'aws-cdk-lib/aws-dynamodb';

// 2. Import CDK enums for the Webhook URL
import { FunctionUrlAuthType, HttpMethod } from 'aws-cdk-lib/aws-lambda';
import {previewAgreement} from "./functions/preview-agreement/resource";

const backend = defineBackend({
    auth,
    data,
    storage,
    statusTracker,
    flutterwaveWebhook, // 3. Add the webhook to the backend deployment
    previewAgreement,
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

// --- Webhook Configuration ---
// 4. Generate a public, unauthenticated URL for Flutterwave to hit
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

backend.statusTracker.resources.lambda.addEventSource(new DynamoEventSource(agreementTable, {
    startingPosition: StartingPosition.LATEST,
}));

backend.statusTracker.resources.lambda.addEventSource(new DynamoEventSource(milestoneTable, {
    startingPosition: StartingPosition.LATEST,
}));
