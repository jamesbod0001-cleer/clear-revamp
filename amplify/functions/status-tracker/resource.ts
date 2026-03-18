import { defineFunction } from '@aws-amplify/backend';

export const statusTracker = defineFunction({
    name: 'status-tracker',
    entry: './handler.ts',
    runtime: 20,
    resourceGroupName: 'data',
});
