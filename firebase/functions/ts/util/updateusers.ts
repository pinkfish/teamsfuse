import * as admin from 'firebase-admin';

const FieldValue = admin.firestore.FieldValue;

export function updateUsers(data: Record<string, any>): Record<string, any> {
    const ret: Record<string, any> = {};
    // Go through the users and make sure there is still a aplyer for each one.
    for (const idx in data) {
        const user = data[idx];
        let found = false;
        for (const player in user) {
            if (player !== 'added') {
                found = true;
            }
        }
        if (!found) {
            ret[user] = FieldValue.delete();
        }
    }
    return ret;
}
