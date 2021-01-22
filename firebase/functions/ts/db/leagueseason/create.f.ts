import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onCreate = functions.firestore.document('/LeagueSeason/{leagueId}').onCreate(async (snap, context) => {
    return algolia.updateLeagueSeason(snap);
});

export default onCreate;
