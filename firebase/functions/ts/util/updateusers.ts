import * as admin from 'firebase-admin';

const FieldValue = admin.firestore.FieldValue;

export function updateUsers(data: Record<string, any>): Record<string, any> {
    const ret: Record<string, any> = {};
    // Go through the users and make sure there is still a a player for each one.
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

export function updateAdmins(admins: Set<string>, oldAdmins: Set<string>): Record<string, any> {
    const ret: Record<string, any> = {};
    for (const idx in admins) {
        // Update the seasons with the admins bits.
        ret[idx].admin = true;
    }

    if (oldAdmins) {
        const difference = new Set([...oldAdmins].filter((x) => !admins.has(x)));
        for (const toRemove in difference) {
            ret[toRemove].admin = FieldValue.delete();
        }
    }
    return ret;
}
