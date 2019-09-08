import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as admin from 'firebase-admin';
import * as _ from 'lodash';
import { updateUsers, updateAdmins } from '../../util/updateusers';

const db = admin.firestore();

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
    if (data && data.users) {
        const newData = updateUsers(data.users);
        if (newData.size > 0) {
            // Do the update.
            ret.push(
                db
                    .collection('Teams')
                    .doc(inputData.after.id)
                    .update(newData),
            );
        }
    }
    if (data && previousData) {
        const adminSet: Set<string> = new Set(_.keys(data.admins));
        const oldAdminSet: Set<string> = new Set(_.keys(previousData.admins));
        if (!_.isEqual(adminSet, oldAdminSet)) {
            const toUpdate = updateAdmins(adminSet, oldAdminSet);
            // Go through all the seasons and update them.
            ret.push(
                db
                    .collection('Seasons')
                    .where('teamUid', '==', inputData.after.id)
                    .get()
                    .then(snap => {
                        const innerRet: Promise<any>[] = [];
                        for (const docIdx in snap.docs) {
                            const doc = snap.docs[docIdx];
                            innerRet.push(
                                db
                                    .collection('Seasons')
                                    .doc(doc.id)
                                    .update(toUpdate),
                            );
                        }
                        return Promise.all(innerRet);
                    }),
            );
        }
    }
    return Promise.all(ret);
});

export default onTeamUpdate;
