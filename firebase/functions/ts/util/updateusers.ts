import * as admin from 'firebase-admin';
import { DocumentSnapshot } from '@google-cloud/firestore';

const FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

interface UsersAndPlayers {
    users: Record<string, any>;
    players: Record<string, any>;
}

// Updates the usersAndPlayers with exciting data when created or updated.
export async function updateUsersAndPlayers(
    players: Record<string, any>,
    users: Record<string, any>,
    force: boolean,
): Promise<UsersAndPlayers> {
    const retUser: Record<string, any> = {};
    const retPlayer: Record<string, any> = {};
    const playerSet: Set<string> = new Set<string>();

    // Go through the users and make sure there is still a a player for each one.
    for (const idx in users) {
        const user = users[idx];
        let found = false;
        for (const player in user) {
            if (player !== 'added') {
                found = true;
                playerSet.add(player);
            }
        }
        if (!found) {
            retUser[user] = FieldValue.delete();
        }
    }

    // go through the players and make sure we have a corresponding user.
    for (let idx in players) {
        idx = idx.trim();
        if (!playerSet.has(idx) || force) {
            // Load the user details from the player and update.
            const playerData = await db.collection('Players').doc(idx).get();
            const playerDataInner = playerData.data();
            if (playerDataInner !== null && playerDataInner !== undefined) {
                for (const newIdx in playerDataInner.user) {
                    if (!(newIdx in retUser)) {
                        if (users === null || users === undefined || !(newIdx in users)) {
                            retUser['users.' + newIdx + '.added'] = true;
                        }
                    }
                    retUser['users.' + newIdx + '.' + idx] = true;
                }
            }
        }
    }
    return { users: retUser, players: retPlayer };
}

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

export function updateAdmins(doc: DocumentSnapshot, admins: Set<string>, oldAdmins: Set<string>): Record<string, any> {
    const ret: Record<string, any> = {};
    for (const idx in admins) {
        // Update the seasons with the admins bits.
        ret['users.' + idx + '.admin'] = true;
        ret['users.' + idx + '.added'] = true;
    }

    if (oldAdmins) {
        const difference = new Set([...oldAdmins].filter((x) => !admins.has(x)));
        for (const toRemove in difference) {
            ret['users.' + toRemove + '.admin'] = FieldValue.delete();
            fixEmptyUser(doc, ret, toRemove, 'admin', false);
        }
    }
    return ret;
}

// CLeanup the user section if a user is completely removed.
export function fixEmptyUser(
    doc: DocumentSnapshot,
    updateData: Record<string, any>,
    user: string,
    specialUser: string,
    updateAdmin: boolean,
): void {
    const docData = doc.data();
    if (docData && docData.users) {
        const users = { ...docData.users };
        if (users) {
            const checkUser = users[user];
            if (checkUser) {
                delete checkUser[specialUser];
                delete checkUser['added'];
                if (Object.keys(checkUser).length === 0) {
                    // Remove the user from the team altogether.
                    updateData['users.' + user] = admin.firestore.FieldValue.delete();
                    delete updateData['users.' + user + '.' + specialUser];
                }
            }
        }
    }
    // See if we should delete the admin too.
    if (updateAdmin) {
        if (docData && docData.admins) {
            const admins = { ...docData.admins };
            if (admins) {
                const checkAdmin = admins[user];
                if (checkAdmin) {
                    delete checkAdmin[specialUser];
                    delete checkAdmin['added'];
                    if (Object.keys(checkAdmin).length === 0) {
                        // Remove the user from the team altogether.
                        updateData['admins.' + user] = admin.firestore.FieldValue.delete();
                        delete updateData['admins.' + user + '.' + specialUser];
                    }
                }
            }
        }
    }
    return;
}
