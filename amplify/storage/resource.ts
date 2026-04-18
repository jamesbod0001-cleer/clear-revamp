import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
    name: 'cleerVault',
    access: (allow) => ({
        'public/users/{entity_id}/*': [
            allow.guest.to(['read']),
            allow.authenticated.to(['read']),
            allow.entity('identity').to(['read', 'write', 'delete'])
        ],
    })
});
