import { defineFunction } from '@aws-amplify/backend';

export const syncMilestoneToAgreement = defineFunction({
    name: 'sync-milestone-to-agreement',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
});
