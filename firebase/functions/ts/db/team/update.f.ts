import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onTeamUpdate = functions.firestore.document('/Team/{leagueId}').onUpdate((inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    // See if the name changed.
    if (previousData!.name === null || previousData!.name !== data!.name) {
        return algolia.updateTeam(inputData.after);
    }
    return data;
});

export default onTeamUpdate;
