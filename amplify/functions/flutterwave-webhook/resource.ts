import { defineFunction, secret } from '@aws-amplify/backend';

export const flutterwaveWebhook = defineFunction({
    name: 'flutterwave-webhook',
    entry: './handler.ts',
    runtime: 20,
    resourceGroupName: 'data',
    environment: {
        // This makes the secret available as an environment variable in the handler
        FLW_SECRET_HASH: secret('FLW_SECRET_HASH'),
        FLW_PROD_CLIENT_ID: secret('FLW_PROD_CLIENT_ID'),
        FLW_PROD_CLIENT_SECRET: secret('FLW_PROD_CLIENT_SECRET'),
        FLW_SANDBOX_CLIENT_ID: secret('FLW_SANDBOX_CLIENT_ID'),
        FLW_SANDBOX_CLIENT_SECRET: secret('FLW_SANDBOX_CLIENT_SECRET'),
        AMPLIFY_DATA_BUSINESS_ENV: process.env.BRANCH_NAME === 'main' ? 'prod' : 'sandbox'
    }
});
