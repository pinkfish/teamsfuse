import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { updateUsers } from '../../util/updateusers';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onSeasonUpdate = functions.firestore.document('/Sessons/{seasonId}').onUpdate((inputData, context) => {
    const data = inputData.after.data();

    // Fix the users section.
    if (data && data.users) {
        const newData = updateUsers(data.users);
        if (newData.size > 0) {
            // Do the update.
            return db.collection('Seasons').doc(inputData.after.id).update(newData);
        }
    }
    return data;
});

export default onSeasonUpdate;
