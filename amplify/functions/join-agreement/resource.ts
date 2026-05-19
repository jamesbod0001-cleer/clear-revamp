import { defineFunction } from '@aws-amplify/backend';

export const joinAgreement = defineFunction({
    name: 'join-agreement',
    entry: './handler.ts',
    timeoutSeconds: 15, // Give it a little extra time in case there are many milestones
    runtime: 24,
    resourceGroupName: 'data'
});
