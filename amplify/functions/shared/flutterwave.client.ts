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

export interface CreateRefundParams {
    chargeId: string;
    amount: number;
    reason: string;
    accessToken: string;
    businessEnv: string;
}

export async function createRefund(params: CreateRefundParams) {
    logger.info(`Initiating refund for charge ID: ${params.chargeId}, amount: ${params.amount}`);
    const baseUrl = getBaseUrl(params.businessEnv);

    const response = await fetch(`${baseUrl}/refunds`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${params.accessToken}`
        },
        body: JSON.stringify({
            charge_id: params.chargeId,
            amount: params.amount,
            reason: params.reason
        })
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Refund failed with status ${response.status}: ${errorText}`);
    }

    return await response.json();
}

export async function listChargesByVirtualAccount(virtualAccountId: string, accessToken: string, businessEnv: string) {
    logger.info(`Listing charges for Virtual Account ID: ${virtualAccountId}`);
    const baseUrl = getBaseUrl(businessEnv);

    const response = await fetch(`${baseUrl}/charges?virtual_account_id=${virtualAccountId}`, {
        method: 'GET',
        headers: {
            'Accept': 'application/json',
            'Authorization': `Bearer ${accessToken}`
        }
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Failed to list charges for virtual account with status ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    return data.data || [];
}
