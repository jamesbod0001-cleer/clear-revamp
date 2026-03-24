import { util } from '@aws-appsync/utils';

// This tells AppSync: "I don't need to talk to a database, just proceed"
export function request(ctx) {
    return { payload: null };
}

// This returns the current server time in ISO8601 format
export function response(ctx) {
    return util.time.nowISO8601();
}
