import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onUpdate = functions.firestore
    .document('/LeagueSeason/{leagueId}')
    .onUpdate(async (inputData, context) => {
        const previousData = inputData.before.data();
        const data = inputData.after.data();

        // See if the name changed.
        if (previousData.name === null || previousData.name !== data.name) {
            return algolia.updateLeagueSeason(inputData.after);
        }
    });

export default onUpdate;
