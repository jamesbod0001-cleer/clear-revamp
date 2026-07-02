import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
    name: 'cleerVault',
    access: (allow) => ({
        'public/users/{entity_id}/*': [
            allow.guest.to(['read']),
            allow.authenticated.to(['read']),
            allow.entity('identity').to(['read', 'write', 'delete'])
        ],
        'agreements/*': [
            // Allows both buyer and vendor to upload and view files
            allow.authenticated.to(['read', 'write']),
            //
            // // Allows your customer support team to review evidence during a DISPUTE
            // allow.groups(['Admin']).to(['read', 'write', 'delete'])
        ]
    })
});
