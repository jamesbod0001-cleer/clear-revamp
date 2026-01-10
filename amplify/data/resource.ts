import { type ClientSchema, a, defineData } from '@aws-amplify/backend';
import {User} from "./models/user";

const schema = a.schema({
    User,
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
    schema,
    authorizationModes: {
        defaultAuthorizationMode: 'userPool',
    },
});