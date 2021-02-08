import * as admin from 'firebase-admin';

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
    console.log('do it');

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
        console.log('player "' + idx + '"');
        idx = idx.trim();
        if (!playerSet.has(idx) || force) {
            // Load the user details from the player and update.
            const playerData = await db.collection('Players').doc(idx).get();
            const playerDataInner = playerData.data();
            console.log(playerDataInner);
            if (playerDataInner !== null && playerDataInner !== undefined) {
                for (const newIdx in playerDataInner.user) {
                    retUser[newIds + '.added'] = true;
                    retUser[newIdx + '.' + idx] = true;
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
