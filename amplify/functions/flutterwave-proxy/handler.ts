// amplify/functions/flutterwave-proxy/handler.ts

import type { Schema } from "../../data/resource";
import { env } from '$amplify/env/flutterwave-proxy';
import { Logger } from "@aws-lambda-powertools/logger";
// Import the centralized base URL utility
import { getBaseUrl, getAccessToken as fetchNewToken } from "../shared/flutterwave.client";

const logger = new Logger({ logLevel: "INFO", serviceName: "flutterwave-proxy" });

// Cold start cache variables preserved in the warm container memory
let cachedToken: string | null = null;
let tokenExpiryTime: number = 0;

export const handler: Schema["flutterwaveProxy"]["functionHandler"] = async (event) => {
    const { method, endpoint, payload, headers } = event.arguments;

    logger.info("--- PROXY INVOCATION START ---", { method, endpoint });

    try {
        const responseData = await executeWithTokenRetry(method, endpoint, payload, headers);
        logger.info("Proxy request successful");
        return JSON.stringify(responseData);

    } catch (error: any) {
        if (error.name && error.name !== 'Error') {
            logger.error(`[Proxy Error] Code: ${error.name}`, { error_message: error.message });
            throw error;
        }

        logger.error('Unhandled Proxy Error', { error });
        const fallbackError = new Error('Payment gateway error.');
        fallbackError.name = '500';
        throw fallbackError;
    }
};

// --- HELPER FUNCTIONS ---

async function executeWithTokenRetry(
    method: string,
    endpoint: string,
    payload?: string | null,
    headers?: string | null
) {
    let token = await getAccessToken();

    try {
        return await proxyRequest(method, endpoint, token, payload, headers);
    } catch (error: any) {
        if (error.name === '10401') {
            logger.warn("Cached token was rejected by Flutterwave. Forcing refresh and retry...");

            cachedToken = null;
            tokenExpiryTime = 0;

            token = await getAccessToken();
            return await proxyRequest(method, endpoint, token, payload, headers);
        }
        throw error;
    }
}

async function getAccessToken(): Promise<string> {
    const now = Date.now();

    if (cachedToken && now < tokenExpiryTime) {
        logger.info("Using cached Flutterwave Token.");
        return cachedToken;
    }

    logger.info("Cache expired or empty. Delegating token generation to shared client...");

    const environment = env.AMPLIFY_DATA_BUSINESS_ENV || 'sandbox';

    // Natively utilize your shared config injection protocol
    const token = await fetchNewToken({
        clientId: environment === 'prod' ? env.FLW_PROD_CLIENT_ID! : env.FLW_SANDBOX_CLIENT_ID!,
        clientSecret: environment === 'prod' ? env.FLW_PROD_CLIENT_SECRET! : env.FLW_SANDBOX_CLIENT_SECRET!,
        businessEnv: environment
    });

    cachedToken = token;

    // Maintain local safety buffer evaluation blocks
    const lifespanSeconds = 15 * 60;
    const safetyBufferMs = 60 * 1000;
    tokenExpiryTime = now + (lifespanSeconds * 1000) - safetyBufferMs;

    logger.info("New token successfully locked into proxy container memory.");
    return cachedToken as string;
}

async function proxyRequest(
    method: string,
    endpoint: string,
    token: string,
    payload?: string | null,
    customHeadersStr?: string | null
) {
    const environment = env.AMPLIFY_DATA_BUSINESS_ENV || 'sandbox';

    // Resolved cleanly via the shared library function instead of hardcoded strings
    const baseUrl = getBaseUrl(environment);
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
        throw error;
    }

    return data;
}
