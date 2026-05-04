import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { storage } from "./storage/resource";

import { flutterwaveWebhook } from "./functions/flutterwave-webhook/resource";

// CDK imports for DynamoDB Streams
import { DynamoEventSource } from 'aws-cdk-lib/aws-lambda-event-sources';
import { StartingPosition, FilterCriteria, FilterRule } from 'aws-cdk-lib/aws-lambda';
import { StreamViewType } from 'aws-cdk-lib/aws-dynamodb';

import { FunctionUrlAuthType, HttpMethod } from 'aws-cdk-lib/aws-lambda';
import {previewAgreement} from "./functions/preview-agreement/resource";
import {logAgreementStatus} from "./functions/log-agreement-status/resource";
import {logMilestoneStatus} from "./functions/log-milestone-status/resource";

const backend = defineBackend({
    auth,
    data,
    storage,
    logAgreementStatus,
    logMilestoneStatus,
    flutterwaveWebhook,
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
cfnUserPool.usernameAttributes = [];
cfnUserPool.aliasAttributes = ['phone_number','email'];

// --- Webhook Configuration ---
// Generate a public, unauthenticated URL for Flutterwave to hit
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

const statusChangeFilter = FilterCriteria.filter({
    eventName: FilterRule.or('INSERT', 'MODIFY'),
    dynamodb: {
        NewImage: {
            status: { S: FilterRule.exists() } // Only matches if the status field is present in the update
        }
    }
});

// Sniper 1 (Agreement) with the filter
backend.logAgreementStatus.resources.lambda.addEventSource(
    new DynamoEventSource(agreementTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [statusChangeFilter],
    })
);

// Sniper 2 (Milestone) with the filter
backend.logMilestoneStatus.resources.lambda.addEventSource(
    new DynamoEventSource(milestoneTable, {
        startingPosition: StartingPosition.LATEST,
        filters: [statusChangeFilter],
    })
);
