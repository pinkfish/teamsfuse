import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamDelete = functions.firestore.document('/Teams/{teamId}').onDelete((snap, context) => {
    return algolia.deleteTeam(snap.id);
});

export default onTeamDelete;
