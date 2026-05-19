import { defineFunction } from '@aws-amplify/backend';

export const previewAgreement = defineFunction({
    name: 'preview-agreement',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data'
});
