import { defineFunction } from '@aws-amplify/backend';

export const evaluateDeadlines = defineFunction({
    name: 'evaluate-deadlines',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
    timeoutSeconds: 300, // 5 minutes max
    environment: {
        AMPLIFY_DATA_BUSINESS_ENV: process.env.AWS_BRANCH === 'main' ? 'prod' : 'sandbox'
    }
});
