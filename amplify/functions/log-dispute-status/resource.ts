import { defineFunction } from '@aws-amplify/backend';

export const logDisputeStatus = defineFunction({
    name: 'log-dispute-status',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
});
