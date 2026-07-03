import type { Schema } from "../../data/resource";
import { env } from '$amplify/env/flutterwave-proxy';
import { Logger } from "@aws-lambda-powertools/logger";

const logger = new Logger({ logLevel: "INFO", serviceName: "flutterwave-proxy" });

// Cold start cache variables preserved in the warm container
let cachedToken: string | null = null;
let tokenExpiryTime: number = 0;

export const handler: Schema["flutterwaveProxy"]["functionHandler"] = async (event) => {
    const { method, endpoint, payload, headers } = event.arguments;

    logger.info("--- PROXY INVOCATION START ---", { method, endpoint });

    try {
        // All retry logic is now handled cleanly by the helper function
        const responseData = await executeWithTokenRetry(method, endpoint, payload, headers);

        logger.info("Proxy request successful");
        return JSON.stringify(responseData);

    } catch (error: any) {
        // We only catch errors ONCE here at the top level
        if (error.name && error.name !== 'Error') {
            logger.error(`[Proxy Error] Code: ${error.name}`, { error_message: error.message });
            throw error; // AppSync maps this error.name to errorType
        }

        logger.error('Unhandled Proxy Error', { error });
        const fallbackError = new Error('Payment gateway error.');
        fallbackError.name = '500';
        throw fallbackError;
    }
};

// --- HELPER FUNCTIONS ---

/**
 * Handles fetching the token and executing the request.
 * If the token is rejected (10401), it forces a refresh and retries once.
 */
async function executeWithTokenRetry(
    method: string,
    endpoint: string,
    payload?: string | null,
    headers?: string | null
) {
    let token = await getAccessToken();

    try {
        // First attempt
        return await proxyRequest(method, endpoint, token, payload, headers);
    } catch (error: any) {
        // If unauthorized, clear cache and retry exactly once
        if (error.name === '10401') {
            logger.warn("Cached token was rejected by Flutterwave. Forcing refresh and retry...");

            cachedToken = null;
            tokenExpiryTime = 0;

            token = await getAccessToken(); // Fetch new token

            // Second attempt (if this fails, it throws directly to the main handler)
            return await proxyRequest(method, endpoint, token, payload, headers);
        }

        // Any other error is thrown directly to the main handler, avoiding local catches
        throw error;
    }
}

async function getAccessToken(): Promise<string> {
    const now = Date.now();

    if (cachedToken && now < tokenExpiryTime) {
        logger.info("Using cached Flutterwave Token.");
        return cachedToken;
    }

    logger.info("Fetching new Flutterwave Token...");

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

    const lifespanSeconds = data.expires_in ? Number(data.expires_in) : 15 * 60;
    const safetyBufferMs = 60 * 1000;

    tokenExpiryTime = now + (lifespanSeconds * 1000) - safetyBufferMs;

    logger.info("New token fetched and cached successfully", { token_lifespan_sec: lifespanSeconds });
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

    const requestHeaders: Record<string, string> = {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
    };

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

    if (!response.ok || data.status === 'failed') {
        const fwCode = data?.error?.code || response.status.toString() || 'FW_UNKNOWN_ERROR';
        const fwMessage = data?.error?.message || 'Flutterwave transaction failed';

        logger.warn("Flutterwave returned an error response", { code: fwCode, fw_message: fwMessage });

        const error = new Error(fwMessage);
        error.name = fwCode;

        if (data?.errors) {
            (error as any).validationErrors = JSON.stringify(data.errors);
        }
        throw error; // This now safely bubbles up exactly one level
    }

    return data;
}
