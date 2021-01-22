import * as functions from 'firebase-functions';
import * as algolia from '../../util/algolia';
import * as admin from 'firebase-admin';
import { createGameFromShared } from '../../util/creategame';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onWrite = functions.firestore.document('/LeagueTeam/{teamId}').onWrite(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before !== null ? inputData.before.data() : null;

    // See if we added in a seasonUid into the setup.
    if (
        data !== null &&
        data !== undefined &&
        data.seasonUid !== null &&
        data.seasonUid !== undefined &&
        (previousData === null || previousData === undefined || previousData.seasonUid !== data.seasonUid)
    ) {
        // The season changed.  Make sure it is not
        // an empty strind and that we have a team uid
        // too.
        if (data.seasonUid !== '' && data.teamUid !== null && data.teamUid !== '') {
            // Look for all the games with this leagueteam setup
            // on them.
            const snap = await db
                .collection('GamesShared')
                .where('officialResult.awayTeamUid', '==', inputData.after.id)
                .get();

            for (const index in snap.docs) {
                const doc = snap.docs[index];
                // Create a game for this.
                await createGameFromShared(doc, inputData.after);
            }

            // Do the home teams too.
            const snappy = await db
                .collection('GamesShared')
                .where('officialResult.homeTeamUid', '==', inputData.after.id)
                .get();

            for (const indexHome in snappy.docs) {
                const docHome = snappy.docs[indexHome];
                // Create a game for this.
                await createGameFromShared(docHome, inputData.after);
            }
        }
    }

    // Update algolia
    if (data !== null && data !== undefined) {
        if (previousData !== null && previousData !== undefined) {
            if (previousData.name !== data.name) {
                await algolia.updateLeagueTeam(inputData.after);
            }
        } else {
            await algolia.updateLeagueTeam(inputData.after);
        }
    }
    if (data === null || data === undefined) {
        await algolia.deleteLeagueTeam(inputData.before.id);
    }
    return;
});

export default onWrite;
