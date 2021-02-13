import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

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
        await db.collection('Seasons').doc(doc.id).update(updateData);
        await db.collection('Teams').doc(doc.data().teamUid).update(updateData);
    }
    return;
}

export default onPlayerWrite;
