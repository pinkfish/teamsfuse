import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

export const onPlayerWrite = functions.firestore.document('/Players/{playerid}').onWrite((inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    if (!data) {
        return data;
    }
    // If we have a new user, update this everywhere.
    const ret: Promise<any>[] = [];
    for (const user in data.user) {
        if (!previousData || !(user in previousData.user)) {
            ret.push(addUser(user, inputData.after.id));
        }
    }
    if (previousData) {
        for (const user in previousData.user) {
            if (!(user in data.user)) {
                ret.push(removeUser(user, inputData.after.id));
            }
        }
    }

    return Promise.all(ret);
});

async function addUser(user: string, playerId: string): Promise<any> {
    // Add this user everywhere.
    return db
        .collection('Seasons')
        .where('players.' + playerId + '.added', '==', true)
        .get()
        .then(snapshot => {
            const innerRet: Promise<any>[] = [];
            snapshot.docs.forEach(doc => {
                const updateData: Record<string, any> = {};
                updateData['users.' + user + '.added'] = true;
                updateData['users.' + user + '.' + playerId] = true;
                innerRet.push(
                    db
                        .collection('Seasons')
                        .doc(doc.id)
                        .update(updateData),
                );
                innerRet.push(
                    db
                        .collection('Teams')
                        .doc(doc.data().teamUid)
                        .update(updateData),
                );
            });
            return Promise.all(innerRet);
        });
}

async function removeUser(user: string, playerId: string): Promise<any> {
    // Delete this user everywhere.
    return db
        .collection('Seasons')
        .where('players.' + playerId + '.added', '==', true)
        .get()
        .then(snapshot => {
            const innerRet: Promise<any>[] = [];
            snapshot.docs.forEach(doc => {
                // Remove just the player, or everything.
                const updateData: Record<string, any> = {};
                updateData['users.' + user + '.' + playerId] = FieldValue.delete();
                innerRet.push(
                    db
                        .collection('Seasons')
                        .doc(doc.id)
                        .update(updateData),
                );
                innerRet.push(
                    db
                        .collection('Teams')
                        .doc(doc.data().teamUid)
                        .update(updateData),
                );
            });
            return Promise.all(innerRet);
        });
}

export default onPlayerWrite;
