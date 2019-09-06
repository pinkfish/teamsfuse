import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamCreate = functions.firestore.document('/Teams/{teamId}').onCreate((snap, context) => {
    return algolia.updateTeam(snap);
});

export default onTeamCreate;
