import { Amplify } from 'aws-amplify';
import { generateClient } from 'aws-amplify/data';
import { getAmplifyDataClientConfig } from '@aws-amplify/backend/function/runtime';
import { env } from '$amplify/env/join-agreement';
import type { Schema } from '../../data/resource';

const { resourceConfig, libraryOptions } = await getAmplifyDataClientConfig(env);
Amplify.configure(resourceConfig, libraryOptions);

const client = generateClient<Schema>();

export const handler: Schema['joinAgreement']['functionHandler'] = async (event) => {
    const { shortCode } = event.arguments;

    // 1. Securely extract the caller's Cognito User ID
    // event.identity is populated by AppSync when using userPool auth
    const identity = event.identity as any;
    const callerId = identity?.sub;

    if (!callerId) {
        throw new Error("Unauthorized: Could not verify user identity.");
    }

    // 2. Fetch the Agreement
    const { data: agreements, errors } = await client.models.Agreement.list({
        filter: { shortCode: { eq: shortCode } }
    });

    if (errors || !agreements || agreements.length === 0) {
        throw new Error("Agreement not found or database error.");
    }

    const item = agreements[0];
    const participants = item.participants || [];

    // 3. IDEMPOTENCY CHECK: Are they already in the participants array?
    if (participants.includes(callerId)) {
        // They are already in! Return the ID immediately so the frontend can proceed.
        console.log(`User ${callerId} is already a participant of ${item.id}.`);
        return item.id;
    }

    // 4. Figure out their role based on who created it
    const isCallerSender = item.initiatorRole === 'RECIPIENT';
    const isCallerRecipient = item.initiatorRole === 'SENDER';

    // 5. Update the Agreement (Add to participants AND assign role ID)
    try {
        await client.models.Agreement.update({
            id: item.id,
            participants: [...participants, callerId],
            // Conditionally set the missing role ID
            ...(isCallerSender ? { senderId: callerId } : {}),
            ...(isCallerRecipient ? { recipientId: callerId } : {})
        });
        console.log(`Successfully added user ${callerId} to Agreement ${item.id}.`);
    } catch (e) {
        console.error("Failed to update Agreement:", e);
        throw new Error("Failed to join agreement.");
    }

    // 6. Update all associated Milestones (if any)
    if (item.disbursementType === 'MILESTONES') {
        const { data: milestones } = await client.models.Milestone.list({
            filter: { agreementId: { eq: item.id } }
        });

        if (milestones && milestones.length > 0) {
            // Update them all in parallel for blazing speed
            await Promise.all(milestones.map(async (ms) => {
                const msParticipants = ms.participants || [];
                if (!msParticipants.includes(callerId)) {
                    return client.models.Milestone.update({
                        id: ms.id,
                        participants: [...msParticipants, callerId]
                    });
                }
            }));
            console.log(`Successfully added user ${callerId} to all milestones.`);
        }
    }

    // 7. Return the agreement ID back to the Flutter app!
    return item.id;
};
