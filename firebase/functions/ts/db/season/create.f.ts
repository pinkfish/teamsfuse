import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { updateUsersAndPlayers } from '../../util/updateusers';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onSeasonCreate = functions.firestore.document('/Seasons/{seasonId}').onCreate(async (snap, context) => {
    const data = snap.data();

    // If the team is public and this is the current season, update the public bit.
    const team = await db.collection('Teams').doc(data.teamUid).get();
    // If it doesn't exist...?  Hmmm.
    if (team.exists && data !== null && data !== undefined) {
        const teamData = team.data();
        if (teamData !== null && teamData !== undefined && teamData.isPublic) {
            // Yay us.
            if (teamData.currentSeason === snap.id) {
                // Set all the others as not visible.
                const otherSeasons = await db.collection('Seasons').where('teamUid', '==', data.teamUid).get();
                for (const doc of otherSeasons.docs) {
                    const docData = doc.data();
                    if (docData !== null && docData !== undefined) {
                        if (doc.id === teamData.currentSeason) {
                            if (!docData.isPublic) {
                                await doc.ref.update({
                                    isPublic: true,
                                });
                            }
                        } else {
                            if (docData.isPublic) {
                                await doc.ref.update({ isPublic: false });
                            }
                        }
                    }
                }
            }
        } else if (data.isPublic) {
            await snap.ref.update({ isPublic: false });
        }
    } else if (data.isPublic) {
        await snap.ref.update({ isPublic: false });
    }

    if (data !== null && data !== undefined) {
        const newData = await updateUsersAndPlayers(data.players, data.users);
        if (Object.keys(newData).length > 0) {
            // Do the update.
            await snap.ref.update({users: newData});
        }
    }

    return data;
});

export default onSeasonCreate;
