"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const algolia = require("../util/algolia");

var db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore
  .document("/LeagueDivision/{leagueId}")
  .onUpdate((inputData, context) => {
    var finalRet = [];
    const data = inputData.after.data();

    // See if the name changed.
    if (previousData.name === null || previousData.name !== data.name) {
      algolia.updateLeagueDivison(inputData.after);
    }
  });

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore
  .document("/LeagueDivision/{leagueId}")
  .onCreate((snap, context) => {
    algolia.updateLeagueDivison(snap);
  });
