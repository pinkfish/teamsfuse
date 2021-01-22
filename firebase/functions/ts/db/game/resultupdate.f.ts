import * as functions from 'firebase-functions';
import { updateTeam } from './gameresultupdateteam';

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onWrite = functions.firestore.document('/Games/{gameid}').onWrite(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before !== null ? inputData.before.data() : null;

    if (data === null || data === undefined) {
        console.log('no data at all');
        return;
    }
    if (previousData === null || previousData === undefined) {
        console.log('no data at all');
        return;
    }

    // Created with this, or updates with this result.
    if (
        data.result !== null &&
        data.result.inProgress === 'Final' &&
        (previousData === null ||
            data.result.inProgress !== previousData.result.inProgress ||
            data.result.result !== previousData.result.result)
    ) {
        await updateTeam(data.teamUid, data.seasonUid, data.opponentUid);
    } else {
        console.log('Igorning ' + data.result.inProgress + ' ' + data.result.result);
    }
    return;
});
