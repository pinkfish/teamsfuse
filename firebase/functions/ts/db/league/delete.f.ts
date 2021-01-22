import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onDelete = functions.firestore.document('/League/{leagueId}').onDelete(async (snap, context) => {
    await algolia.deleteLeague(snap.id);
});

export default onDelete;
