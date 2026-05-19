import { defineFunction } from '@aws-amplify/backend';

export const logMilestoneStatus = defineFunction({
    name: 'log-milestone-status',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
});
