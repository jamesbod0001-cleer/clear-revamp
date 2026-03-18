// amplify/functions/flutterwave-webhook/flutterwave.client.ts
import { env } from '$amplify/env/flutterwave-webhook';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ serviceName: "flutterwave-client" });

const IS_PROD = env.AMPLIFY_DATA_BUSINESS_ENV === 'prod';
const BASE_URL = IS_PROD
    ? 'https://f4bexperience.flutterwave.com'
    : 'https://developersandbox-api.flutterwave.com';

const CLIENT_ID = IS_PROD ? env.FLW_PROD_CLIENT_ID : env.FLW_SANDBOX_CLIENT_ID;
const CLIENT_SECRET = IS_PROD ? env.FLW_PROD_CLIENT_SECRET : env.FLW_SANDBOX_CLIENT_SECRET;

export async function getAccessToken(): Promise<string> {
    logger.info(`Requesting access token for ${IS_PROD ? 'PROD' : 'SANDBOX'} environment`);

    try {
        const response = await fetch('https://idp.flutterwave.com/realms/flutterwave/protocol/openid-connect/token', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                client_id: CLIENT_ID!,
                client_secret: CLIENT_SECRET!,
                grant_type: 'client_credentials'
            })
        });

        // 1. Explicitly check for HTTP errors
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Auth failed with status ${response.status}: ${errorText}`);
        }

        const data = await response.json();
        return data.access_token;
    } catch (error) {
        // 2. Log the exact failure
        logger.error('Failed to get Flutterwave access token', { error });
        throw error; // Rethrow so the main handler can catch it and return a 500
    }
}

export async function verifyCharge(flwId: string, accessToken: string) {
    logger.info(`Verifying charge ID: ${flwId}`);

    try {
        const response = await fetch(`${BASE_URL}/charges/${flwId}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Verification failed with status ${response.status}: ${errorText}`);
        }

        return await response.json();
    } catch (error) {
        logger.error(`Failed to verify charge ${flwId}`, { error });
        throw error;
    }
}
