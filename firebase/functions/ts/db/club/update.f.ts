import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DocumentSnapshot } from '@google-cloud/firestore';

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

//
// Make sure we keep the users updated correctly on the teams and seasons associated with this player.
//
export const onClubWrite = functions.firestore.document('/Clubs/{playerid}').onWrite(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    if (!data) {
        return data;
    }
    // If we have a new user, update this everywhere.
    for (const user in data.members) {
        if (!previousData || !(user in previousData.members)) {
         console.log('Add ' + user);

            await addUser(inputData.after.id, user, data.members[user].admin ?? false);
        }
    }
    if (previousData) {
        for (const user in previousData.members) {
            if (!(user in data.members)) {
                await removeUser(inputData.after.id, user);
            }
        }
    }

    return;
});

// Add this user to the team/seasons.
async function addUser(clubUid: string, user: string, adminClub: boolean): Promise<any> {
    // Add this user everywhere.
    const snapshot = await db.collection('Teams').where('clubUid', '==', clubUid).get();
    for (const idx in snapshot.docs) {
        const doc = snapshot.docs[idx];
        const updateData: Record<string, any> = {};
        updateData['users.' + user + '.added'] = true;
        updateData['users.' + user + '.club'] = true;
        if (adminClub) {
            updateData['admins.' + user] = true;
        }

        await db.collection('Teams').doc(doc.id).update(updateData);
     console.log('Team ' + doc.id);

        // Get the seasons.
        const seasomSnapshot = await db.collection('Seasons').where('teamUid', '==', doc.id).get();
        for (const seasonIdx in seasomSnapshot.docs) {
            const seasonDoc = seasomSnapshot.docs[seasonIdx];
            console.log('Season ' + seasonDoc.id);

            await db.collection('Seasons').doc(seasonDoc.id).update(updateData);
        }
    }
    return;
}

// CLeanup the user section if a user is completely removed.
function fixEmptyUser(doc: DocumentSnapshot, updateData: Record<string, any>, user: string): void {
    const docData = doc.data();
    if (docData && docData.users) {
        const users = { ...docData.users };
        if (users) {
            const checkUser = users[user];
            if (checkUser) {
                delete checkUser['club'];
                delete checkUser['added'];
                if (Object.keys(checkUser).length === 0) {
                    // Remove the user from the team altogether.
                    updateData['users.' + user] = admin.firestore.FieldValue.delete();
                    delete updateData['users.' + user + '.club'];
                }
            }
        }
    }
    return;
}

// Remove this specific user from the user/seasons.
async function removeUser(clubUid: string, user: string): Promise<any> {
    // Delete this user everywhere.
    const snapshot = await db.collection('Teams').where('clubUid', '==', clubUid).get();
    for (const idx in snapshot.docs) {
        const doc = snapshot.docs[idx];
        // Remove just the player, or everything.
        const updateData: Record<string, any> = {};
        updateData['users.' + user + '.club'] = FieldValue.delete();

        // Check and see if we need to remove the user altogether from the seasons/teams.
        const teamDoc = await db.collection('Teams').doc(doc.id).get();

        fixEmptyUser(teamDoc, updateData, user);

        await db.collection('Teams').doc(doc.id).update(updateData);

        // Get the seasons.
        const seasomSnapshot = await db.collection('Seasons').where('teamUid', '==', doc.id).get();
        for (const seasonIdx in seasomSnapshot.docs) {
            const seasonDoc = seasomSnapshot.docs[seasonIdx];

            fixEmptyUser(seasonDoc, updateData, user);

            await db.collection('Seasons').doc(seasonDoc.id).update(updateData);
        }
    }
    return;
}

export default onClubWrite;
