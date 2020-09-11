'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const createGame = require('../util/creategame');
const algolia = require('../util/algolia');

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore.document('/LeagueTeam/{teamId}').onWrite((inputData, context) => {
    const finalRet = [];
    const data = inputData.after.data();
    const previousData = inputData.before !== null ? inputData.before.data() : null;

    // See if we added in a seasonUid into the setup.
    if (
        data !== null &&
        data.seasonUid !== null &&
        (previousData === null || previousData.seasonUid !== data.seasonUid)
    ) {
        // The season changed.  Make sure it is not
        // an empty strind and that we have a team uid
        // too.
        if (data.seasonUid !== '' && data.teamUid !== null && data.teamUid !== '') {
            // Look for all the games with this leagueteam setup
            // on them.
            finalRet.push(
                db
                    .collection('GamesShared')
                    .where('officialResult.awayTeamUid', '==', inputData.after.id)
                    .get()
                    .then((snap) => {
                        const ret = [];
                        for (const index in snap.docs) {
                            const doc = snap.docs[index];
                            // Create a game for this.
                            ret.push(createGame.createGameFromShared(doc, inputData.after));
                        }
                        return Promise.all(ret);
                    }),
            );
            // Do the home teams too.
            finalRet.push(
                db
                    .collection('GamesShared')
                    .where('officialResult.homeTeamUid', '==', inputData.after.id)
                    .get()
                    .then((snap) => {
                        const retHome = [];
                        for (const indexHome in snap.docs) {
                            const docHome = snap.docs[indexHome];
                            // Create a game for this.
                            retHome.push(createGame.createGameFromShared(docHome, inputData.after));
                        }
                        return Promise.all(retHome);
                    }),
            );
        }
    }

    // Update algolia
    if (previousData === null || previousData.name !== data.name) {
        finalRet.push(algolia.updateLeagueTeam(db, inputData.after));
    }
    if (data === null) {
        finalRet.push(algolia.deleteLeagueTeam(inputData.before));
    }
    return Promise.all(finalRet);
});
