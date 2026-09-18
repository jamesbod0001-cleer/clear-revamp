import { defineFunction, secret } from '@aws-amplify/backend';

export const processRefund = defineFunction({
    name: 'process-refund',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
    timeoutSeconds: 240,
    environment: {
        FLW_PROD_CLIENT_ID: secret('FLW_PROD_CLIENT_ID'),
        FLW_PROD_CLIENT_SECRET: secret('FLW_PROD_CLIENT_SECRET'),
        FLW_SANDBOX_CLIENT_ID: secret('FLW_SANDBOX_CLIENT_ID'),
        FLW_SANDBOX_CLIENT_SECRET: secret('FLW_SANDBOX_CLIENT_SECRET'),
        AMPLIFY_DATA_BUSINESS_ENV: process.env.AMPLIFY_DATA_BUSINESS_ENV || (process.env.AWS_BRANCH === 'main' || process.env.BRANCH_NAME === 'main' ? 'prod' : 'sandbox')
    }
});
