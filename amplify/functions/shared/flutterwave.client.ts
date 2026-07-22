import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ serviceName: "flutterwave-client" });

export interface FlutterwaveConfig {
    clientId: string;
    clientSecret: string;
    businessEnv: string; // 'prod' or 'sandbox'
}

export function getBaseUrl(businessEnv: string): string {
    return businessEnv === 'prod'
        ? 'https://f4bexperience.flutterwave.com'
        : 'https://developersandbox-api.flutterwave.com';
}

export async function getAccessToken(config: FlutterwaveConfig): Promise<string> {
    logger.info(`Requesting access token for ${config.businessEnv} environment`);

    const response = await fetch('https://idp.flutterwave.com/realms/flutterwave/protocol/openid-connect/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            client_id: config.clientId,
            client_secret: config.clientSecret,
            grant_type: 'client_credentials'
        })
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Auth failed with status ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    return data.access_token;
}

export async function verifyCharge(flwId: string, accessToken: string, businessEnv: string) {
    logger.info(`Verifying charge ID: ${flwId}`);
    const baseUrl = getBaseUrl(businessEnv);

    const response = await fetch(`${baseUrl}/charges/${flwId}`, {
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
}
