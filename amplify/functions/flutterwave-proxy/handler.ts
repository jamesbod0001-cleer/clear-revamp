// amplify/functions/flutterwave-proxy/handler.ts

import type { Schema } from "../../data/resource";
import { env } from '$amplify/env/flutterwave-proxy';
import { Logger } from "@aws-lambda-powertools/logger";
import { getBaseUrl, getAccessToken as fetchNewToken } from "../shared/flutterwave.client";

const logger = new Logger({ logLevel: "INFO", serviceName: "flutterwave-proxy" });

let cachedToken: string | null = null;
let tokenExpiryTime: number = 0;

export const handler: Schema["flutterwaveProxy"]["functionHandler"] = async (event) => {
    const { method, endpoint, payload, headers } = event.arguments;

    logger.info("--- PROXY INVOCATION START ---", {
        method,
        endpoint,
        environment: env.AMPLIFY_DATA_BUSINESS_ENV || 'sandbox',
        payload_preview: sanitizePayloadForLog(payload)
    });

    try {
        const responseData = await executeWithTokenRetry(method, endpoint, payload, headers);
        logger.info("Proxy request successful", { endpoint });
        return JSON.stringify(responseData);

    } catch (error: any) {
        logger.error(`[Proxy Error] Code: ${error.name || 'UNKNOWN'}`, {
            error_message: error.message,
            validation_errors: error.validationErrors,
            endpoint,
            stack: error.stack
        });

        if (error.name && error.name !== 'Error') {
            throw error;
        }

        logger.error('Unhandled Proxy Error', { error });
        const fallbackError = new Error('Payment gateway error.');
        fallbackError.name = '500';
        throw fallbackError;
    }
};

function sanitizePayloadForLog(payloadStr?: string | null): string | null {
    if (!payloadStr) return null;
    try {
        const parsed = JSON.parse(payloadStr);
        if (parsed.card) {
            parsed.card = { ...parsed.card, encrypted_card_number: '***', encrypted_cvv: '***' };
        }
        return JSON.stringify(parsed);
    } catch {
        return '[Unparseable Payload]';
    }
}

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
        const errCode = String(error.name || '');
        const errMsg = String(error.message || '').toLowerCase();
        if (errCode === '10401' || errCode === '1138422' || errMsg.includes('jwt expired') || errMsg.includes('unauthorized')) {
            logger.warn(`Cached token was rejected by Flutterwave (Code: ${errCode}, Msg: ${errMsg}). Forcing refresh and retry...`);

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

    const environment = env.AMPLIFY_DATA_BUSINESS_ENV || 'sandbox';

    logger.info(`Fetching new token for environment: ${environment}`);

    const token = await fetchNewToken({
        clientId: environment === 'prod' ? env.FLW_PROD_CLIENT_ID! : env.FLW_SANDBOX_CLIENT_ID!,
        clientSecret: environment === 'prod' ? env.FLW_PROD_CLIENT_SECRET! : env.FLW_SANDBOX_CLIENT_SECRET!,
        businessEnv: environment
    });

    cachedToken = token;

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
    const baseUrl = getBaseUrl(environment);
    const url = `${baseUrl}${endpoint}`;

    logger.info(`Sending ${method} request to Flutterwave: ${url}`, {
        environment,
        payload: sanitizePayloadForLog(payload)
    });

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
    const textData = await response.text();

    let data: any = {};
    try {
        data = JSON.parse(textData);
    } catch (e) {
        logger.error("Failed to parse JSON response from Flutterwave", { status: response.status, raw_response: textData });
        const parseError = new Error(`Flutterwave returned non-JSON response (HTTP ${response.status})`);
        parseError.name = response.status.toString();
        throw parseError;
    }

    if (!response.ok || data.status === 'failed') {
        const fwCode = String(data?.error?.code || data?.code || response.status || 'FW_UNKNOWN_ERROR');
        const fwMessage = data?.error?.message || data?.message || 'Flutterwave transaction failed';

        logger.warn("Flutterwave returned an error response", {
            http_status: response.status,
            fw_code: fwCode,
            fw_message: fwMessage,
            response_body: data,
            endpoint,
            sanitized_payload: sanitizePayloadForLog(payload)
        });

        const error = new Error(fwMessage);
        error.name = fwCode;

        if (data?.errors) {
            (error as any).validationErrors = JSON.stringify(data.errors);
        }
        throw error;
    }

    logger.info("Flutterwave responded successfully", { http_status: response.status, endpoint });
    return data;
}
