import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

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
        if (teamData !== null && teamData !== undefined && teamData.isPublicVisibleTeam) {
            // Yay us.
            if (teamData.currentSeason === snap.id) {
                // Set all the others as not visible.
                const otherSeasons = await db.collection('Seasons').where('teamUid', '==', data.teamUid).get();
                for (const doc of otherSeasons.docs) {
                    const docData = doc.data();
                    if (docData !== null && docData !== undefined) {
                        if (doc.id === teamData.currentSeason) {
                            if (!docData.isPublicVisibleSeason) {
                                await doc.ref.update({
                                    isPublicVisibleSeason: true,
                                });
                            }
                        } else {
                            if (docData.isPublicVisibleSeason) {
                                await doc.ref.update({ isPublicVisibleSeason: false });
                            }
                        }
                    }
                }
            }
        } else if (data.isPublicVisibleSeason) {
            await snap.ref.update({ isPublicVisibleSeason: false });
        }
    } else if (data.isPublicVisibleSeason) {
        await snap.ref.update({ isPublicVisibleSeason: false });
    }
    return data;
});

export default onSeasonCreate;
