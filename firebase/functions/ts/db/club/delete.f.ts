import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as admin from 'firebase-admin';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onClubDelete = functions.firestore.document('/Clubs/{clubId}').onDelete(async (snap, context) => {
    const bucket = admin.storage().bucket();
    try {
        const f = bucket.file('club/club_' + snap.id);
        const exists = await f.exists();
        if (exists) {
            await f.delete();
        }
    } catch (e) {
        console.log('Error deleting image for club ' + snap.id);
    }
    return algolia.deleteClub(snap.id);
});

export default onClubDelete;
