import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import { fixUsers } from './usersfix';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamCreate = functions.firestore.document('/Teams/{teamId}').onCreate(async (snap, context) => {
    await algolia.updateTeam(snap);
    await fixUsers(snap.id, snap.data, { admins: {}, user: {} });
    return;
});

export default onTeamCreate;
