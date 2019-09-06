import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as admin from 'firebase-admin';
import { updateUsers } from './helper';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamUpdate = functions.firestore.document('/Team/{leagueId}').onUpdate((inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    // See if the name changed.
    if (previousData!.name === null || previousData!.name !== data!.name) {
        return algolia.updateTeam(inputData.after);
    }
    if (data && data.users) {
        const newData = updateUsers(data.users);
        if (newData.size > 0) {
            // Do the update.
            return db
                .collection('Team')
                .doc(inputData.after.id)
                .update(newData);
        }
    }
    return data;
});

export default onTeamUpdate;
