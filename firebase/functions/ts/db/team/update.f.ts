import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as _ from 'lodash';
import { fixUsers } from './usersfix';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamUpdate = functions.firestore.document('/Teams/{teamId}').onUpdate((inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    // See if the name changed.
    const ret: Promise<any>[] = [];
    if (previousData!.name === null || previousData!.name !== data!.name) {
        ret.push(algolia.updateTeam(inputData.after));
    }
    ret.push(
        fixUsers(
            inputData.after.id,
            { user: data!.user, admins: data!.admins },
            { user: previousData!.user, admins: previousData!.admins },
        ),
    );

    return Promise.all(ret);
});

export default onTeamUpdate;
