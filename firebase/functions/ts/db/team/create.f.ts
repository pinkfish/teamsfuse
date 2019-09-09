import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import { fixUsers } from './usersfix';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamCreate = functions.firestore.document('/Teams/{teamId}').onCreate((snap, context) => {
    const ret: Promise<any>[] = [];
    ret.push(algolia.updateTeam(snap));
    ret.push(fixUsers(snap.id, snap.data, { admins: {}, user: {} }));
    return Promise.all(ret);
});

export default onTeamCreate;
