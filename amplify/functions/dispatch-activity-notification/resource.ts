import { defineFunction } from '@aws-amplify/backend';

export const dispatchActivityNotification = defineFunction({
    name: 'dispatch-activity-notification',
    entry: './handler.ts',
    runtime: 24,
    resourceGroupName: 'data',
    environment: {
        PINPOINT_APP_ID: 'eb6ecf886702464f8200538bee04719b',
        PINPOINT_REGION: 'eu-west-1'
    }
});
