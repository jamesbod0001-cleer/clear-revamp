import { defineFunction } from '@aws-amplify/backend';

export const logMilestoneStatus = defineFunction({
    name: 'log-milestone-status',
    entry: './handler.ts',
    runtime: 20,
    resourceGroupName: 'data',
});
