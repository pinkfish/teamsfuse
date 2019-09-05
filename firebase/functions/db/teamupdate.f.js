'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const algolia = require('../util/algolia');

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore.document('/Team/{leagueId}').onUpdate((inputData, context) => {
    const finalRet = [];
    const data = inputData.after.data();

    // See if the name changed.
    if (previousData.name === null || previousData.name !== data.name) {
        algolia.updateTeam(inputData.after);
    }
});

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore.document('/Team/{leagueId}').onCreate((snap, context) => {
    algolia.updateTeam(snap);
});

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore.document('/Teams/{leagueId}').onDelete((snap, context) => {
    algolia.deleteTeam(snap.id);
});
