import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a club
// with a specific result we update algolia.
export const onClubCreate = functions.firestore.document('/Clubs/{clubId}').onCreate(async (snap, context) => {
    await algolia.updateClub(snap);
    return;
});

export default onClubCreate;
