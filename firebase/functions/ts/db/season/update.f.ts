import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { updateUsersAndPlayers } from '../../util/updateusers';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onSeasonUpdate = functions.firestore
    .document('/Seasons/{seasonId}')
    .onUpdate(async (inputData, context) => {
        const data = inputData.after.data();

        // Fix the users section.
        if (data) {
            const newData = await updateUsersAndPlayers(data.players, data.users, false);
            if (Object.keys(newData.users).length > 0) {
                // Do the update.
                await db.collection('Seasons').doc(inputData.after.id).update(newData.users);
                await db.collection('Teams').doc(data.teamUid).update(newData.users);
            }
            if (Object.keys(newData.players).length > 0) {
                // Do the update.
                await db.collection('Seasons').doc(inputData.after.id).update({ players: newData.players });
            }
        }
        return data;
    });

export default onSeasonUpdate;
