import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as _ from 'lodash';
import * as admin from 'firebase-admin';
import { fixUsers } from './usersfix';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamUpdate = functions.firestore.document('/Teams/{teamId}').onUpdate(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    if (
        data !== null &&
        data !== undefined &&
        previousData !== null &&
        previousData !== undefined &&
        data.isPublicVisibleTeam !== previousData.isPublicVisibleTeam
    ) {
        if (data.isPublicVisibleTeam) {
            // Became publicaly visible
            await db.collection('Seasons').doc(data.currentSeason).update({
                isPublicVisibleSeason: true,
            });
            const snaps = await db.collection('Seasons').where('teamUid', '==', inputData.after.id).get();
            for (const doc of snaps.docs) {
                if (doc.id === data.currentSeason) {
                    if (!doc.data().isPublicVisibleSeason) {
                        await doc.ref.update({ isPublicVisibleSeason: false });
                    }
                } else if (doc.data().isPublicVisibleSeason) {
                    await doc.ref.update({ isPublicVisibleSeason: false });
                }
            }
        } else {
            // Not visible any more.
            const snaps = await db.collection('Seasons').where('teamUid', '==', inputData.after.id).get();
            for (const doc of snaps.docs) {
                if (doc.data().isPublicVisibleSeason) {
                    await doc.ref.update({ isPublicVisibleSeason: false });
                }
            }
        }
    }

    await fixUsers(
        inputData.after.id,
        { user: data!.user, admins: data!.admins },
        { user: previousData!.user, admins: previousData!.admins },
    );

    // See if the name changed.
    const ret: Promise<any>[] = [];
    if (previousData!.name === null || previousData!.name !== data!.name) {
        await algolia.updateTeam(inputData.after);
    }

    return Promise.all(ret);
});

export default onTeamUpdate;
