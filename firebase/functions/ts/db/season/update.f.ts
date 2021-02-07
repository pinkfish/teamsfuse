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
            console.log(newData);
            if (Object.keys(newData.users).length > 0) {
                console.log(newData.users);
                // Do the update.
                return db.collection('Seasons').doc(inputData.after.id).update({ users: newData.users });
            }
            if (Object.keys(newData.players).length > 0) {
                console.log(newData.players);
                // Do the update.
                return db.collection('Seasons').doc(inputData.after.id).update({ players: newData.players });
            }
        }
        return data;
    });

export default onSeasonUpdate;
