import { defineFunction } from '@aws-amplify/backend';

export const logAgreementStatus = defineFunction({
    name: 'log-agreement-status',
    entry: './handler.ts',
    runtime: 20,
    resourceGroupName: 'data',
});
