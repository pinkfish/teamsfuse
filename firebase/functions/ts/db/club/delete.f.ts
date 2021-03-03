import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onClubDelete = functions.firestore.document('/Clubs/{clubId}').onDelete((snap, context) => {
    return algolia.deleteClub(snap.id);
});

export default onClubDelete;
