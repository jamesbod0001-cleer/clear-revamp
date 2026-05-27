import { defineFunction } from '@aws-amplify/backend';

export const generateAgreementActivity = defineFunction({
    name: 'generate-agreement-activity',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
});
