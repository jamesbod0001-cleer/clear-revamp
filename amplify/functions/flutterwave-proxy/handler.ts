import type { Schema } from "../../data/resource";
import { env } from '$amplify/env/flutterwave-proxy';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ logLevel: "INFO", serviceName: "flutterwave-proxy" });

// Cold start cache
let cachedToken: string | null = null;
let tokenExpiryTime: number = 0;

export const handler: Schema["flutterwaveProxy"]["functionHandler"] = async (event) => {
    const { method, endpoint, payload, headers } = event.arguments;

    logger.info("--- PROXY INVOCATION START ---", { method, endpoint });

    try {
        // Get token (using cached if warm)
        const token = await getAccessToken();

        // Fire request
        const responseData = await proxyRequest(method, endpoint, token, payload, headers);

        logger.info("Proxy request successful");
        return JSON.stringify(responseData);

    } catch (error: any) {
        // Check if we threw a specifically named Flutterwave error
        if (error.name && error.name !== 'Error') {
            logger.error(`[Proxy Error] Code: ${error.name}`, { message: error.message });
            throw error; // AppSync maps this error.name to errorType
        }

        logger.error('Unhandled Proxy Error', { error });
        const fallbackError = new Error('Payment gateway error.');
        fallbackError.name = '500';
        throw fallbackError;
    }
};

// --- HELPER FUNCTIONS ---

async function getAccessToken(): Promise<string> {
    const now = Date.now();

    if (cachedToken && now < tokenExpiryTime) {
        logger.info("Using cached Flutterwave Token.");
        return cachedToken;
    }

    logger.info("Fetching new Flutterwave Token...");

    // Determine environment and secrets dynamically
    const environment = process.env.AMPLIFY_DATA_BUSINESS_ENV || 'sandbox';
    const clientId = environment === 'prod' ? env.FLW_PROD_CLIENT_ID : env.FLW_SANDBOX_CLIENT_ID;
    const clientSecret = environment === 'prod' ? env.FLW_PROD_CLIENT_SECRET : env.FLW_SANDBOX_CLIENT_SECRET;

    const response = await fetch('https://idp.flutterwave.com/realms/flutterwave/protocol/openid-connect/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            'client_id': clientId as string,
            'client_secret': clientSecret as string,
            'grant_type': 'client_credentials'
        }).toString()
    });

    if (!response.ok) {
        logger.error("Failed to authenticate with IDP", { status: response.status });
        throw new Error('Payment authentication failed');
    }

    const data = await response.json();
    cachedToken = data.access_token;
    tokenExpiryTime = now + (55 * 60 * 1000); // Cache for 55 minutes

    return cachedToken as string;
}

async function proxyRequest(
    method: string,
    endpoint: string,
    token: string,
    payload?: string | null,
    customHeadersStr?: string | null
) {
    const environment = process.env.AMPLIFY_DATA_BUSINESS_ENV || 'sandbox';
    const baseUrl = environment === 'prod'
        ? 'https://f4bexperience.flutterwave.com'
        : 'https://developersandbox-api.flutterwave.com';

    const url = `${baseUrl}${endpoint}`;

    // Setup base headers
    const requestHeaders: Record<string, string> = {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
    };

    // Inject Idempotency / Custom headers from Flutter
    if (customHeadersStr) {
        try {
            Object.assign(requestHeaders, JSON.parse(customHeadersStr));
        } catch (e) {
            logger.warn("Failed to parse custom headers", { customHeadersStr });
        }
    }

    const options: RequestInit = {
        method,
        headers: requestHeaders,
    };

    if (payload && (method === 'POST' || method === 'PUT')) {
        options.body = payload;
    }

    const response = await fetch(url, options);
    const data = await response.json();
    // ADVANCED ERROR PARSING: Pass the specific error code back to AppSync
    if (!response.ok || data.status === 'failed') {
        const fwCode = data?.error.code || 'FW_UNKNOWN_ERROR';
        const fwMessage = data?.error.message || 'Flutterwave transaction failed';

        logger.warn("Flutterwave returned an error response", { code: fwCode, message: fwMessage });

        const error = new Error(fwMessage);
        error.name = fwCode; // Sets errorType in AppSync

        if (data?.errors) {
            (error as any).validationErrors = JSON.stringify(data.errors);
        }
        throw error;
    }

    return data;
}
