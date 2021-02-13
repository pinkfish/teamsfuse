import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DocumentSnapshot } from '@google-cloud/firestore';

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

//
// Make sure we keep the users updated correctly on the teams and seasons associated with this player.
//
export const onPlayerWrite = functions.firestore.document('/Players/{playerid}').onWrite(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    if (!data) {
        return data;
    }
    // If we have a new user, update this everywhere.
    for (const user in data.users) {
        if (!previousData || !(user in previousData.users)) {
            await addUser(user, inputData.after.id);
        }
    }
    if (previousData) {
        for (const user in previousData.users) {
            if (!(user in data.users)) {
                await removeUser(user, inputData.after.id);
            }
        }
    }

    return;
});

// Add this user to the team/seasons.
async function addUser(user: string, playerId: string): Promise<any> {
    // Add this user everywhere.
    const snapshot = await db
        .collection('Seasons')
        .where('players.' + playerId + '.added', '==', true)
        .get();
    for (const idx in snapshot.docs) {
        const doc = snapshot.docs[idx];
        const updateData: Record<string, any> = {};
        updateData['users.' + user + '.added'] = true;
        updateData['users.' + user + '.' + playerId] = true;
        // Keep the player set correct as well.
        updateData['players.' + playerId + '.' + user] = true;

        await db.collection('Seasons').doc(doc.id).update(updateData);
        await db.collection('Teams').doc(doc.data().teamUid).update(updateData);
    }
    return;
}

// CLeanup the user section if a user is completely removed.
function fixEmptyUserPlayer(
    doc: DocumentSnapshot,
    updateData: Record<string, any>,
    user: string,
    playerId: string,
): void {
    const docData = doc.data();
    if (docData && docData.users) {
        const users = { ...docData.users };
        if (users) {
            const checkUser = users[user];
            if (checkUser) {
                delete checkUser[playerId];
                delete checkUser['added'];
                if (Object.keys(checkUser).length === 0) {
                    // Remove the user from the team altogether.
                    updateData['users.' + user] = admin.firestore.FieldValue.delete();
                    delete updateData['users.' + user + '.' + playerId];
                       }
            }
        }

    }
    return;
}

// Remove this specific user from the user/seasons.
async function removeUser(user: string, playerId: string): Promise<any> {
    // Delete this user everywhere.
    const snapshot = await db
        .collection('Seasons')
        .where('players.' + playerId + '.added', '==', true)
        .get();
    for (const idx in snapshot.docs) {
        const doc = snapshot.docs[idx];
        // Remove just the player, or everything.
        const updateData: Record<string, any> = {};
        updateData['users.' + user + '.' + playerId] = FieldValue.delete();
        updateData['players.' + playerId + '.' + user] = FieldValue.delete();

        const updateDataSeason: Record<string, any> = { ...updateData };
        // Check and see if we need to remove the user altogether from the seasons/teams.
        const teamDoc = await db.collection('Teams').doc(doc.data().teamUid).get();

        fixEmptyUserPlayer(teamDoc, updateData, user, playerId);

        const seasonDoc = await db.collection('Seasons').doc(doc.data().uid).get();
        fixEmptyUserPlayer(seasonDoc, updateDataSeason, user, playerId);

console.log(updateDataSeason);
console.log(updateData);
        await db.collection('Seasons').doc(doc.id).update(updateDataSeason);
        await db.collection('Teams').doc(doc.data().teamUid).update(updateData);
    }
    return;
}

export default onPlayerWrite;
