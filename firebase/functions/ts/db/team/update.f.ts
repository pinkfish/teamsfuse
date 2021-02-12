import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as _ from 'lodash';
import * as admin from 'firebase-admin';
import { fixUsers } from './usersfix';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamUpdate = functions.firestore.document('/Teams/{teamId}').onUpdate(
    async (inputData, context): Promise<void> => {
        const data = inputData.after.data();
        const previousData = inputData.before.data();

        if (
            data !== null &&
            data !== undefined &&
            previousData !== null &&
            previousData !== undefined &&
            data.isPublic !== previousData.isPublic
        ) {
            if (data.isPublic) {
                // Became publicaly visible
                await db.collection('Seasons').doc(data.currentSeason).update({
                    isPublic: true,
                });
                const snaps = await db.collection('Seasons').where('teamUid', '==', inputData.after.id).get();
                for (const doc of snaps.docs) {
                    if (doc.id === data.currentSeason) {
                        if (!doc.data().isPublic) {
                            await doc.ref.update({ isPublic: false });
                        }
                    } else if (doc.data().isPublic) {
                        await doc.ref.update({ isPublic: false });
                    }
                }
            } else {
                // Not visible any more.
                const snaps = await db.collection('Seasons').where('teamUid', '==', inputData.after.id).get();
                for (const doc of snaps.docs) {
                    if (doc.data().isPublic) {
                        await doc.ref.update({ isPublic: false });
                    }
                }
            }
        }

        await fixUsers(inputData.after.id, data!, previousData!);

        // See if the name changed.
        if (previousData!.name === null || previousData!.name !== data!.name) {
            await algolia.updateTeam(inputData.after);
        }

        return;
    },
);

export default onTeamUpdate;
