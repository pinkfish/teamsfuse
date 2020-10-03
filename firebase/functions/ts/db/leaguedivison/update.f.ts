import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onUpdate = functions.firestore
    .document('/LeagueDivision/{leagueId}')
    .onUpdate(async (inputData, context) => {
        const data = inputData.after.data();
        const previousData = inputData.before.data();

        // See if the name changed.
        if (previousData.name === null || previousData.name !== data.name) {
            await algolia.updateLeagueDivison(inputData.after);
        }
    });

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onCreate = functions.firestore.document('/LeagueDivision/{leagueId}').onCreate(async (snap, context) => {
    await algolia.updateLeagueDivison(snap);
});
