"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const createGame = require("../util/creategame");

var db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore
  .document("/GamesShared/{gameid}")
  .onWrite((inputData, context) => {
    var finalRet = [];
    const data = inputData.after.data();
    const previousData =
      inputData.before !== null ? inputData.before.data() : null;

    var updateGame = db.collection("Games")
        .where("sharedDataUid", "==", inputData.id)
        .get()
        .then(snapshot => {
             if (snapshot.empty) {
               console.log('No matching games?');
               return;
             }

             snapshot.forEach(doc => {
               // Update the data in the doc.
               db.collection("Games").doc(doc.id).update({
                   sharedData: data,
               });
             });
             return ;
           })
           .catch(err => {
             console.log('Error getting documents', err);
           });
    finalRet.push(updateGame);

    // If the team is setup, then we need to go and do a bunch of work to connect the
    // shared games to the real time.
    if (
      data.officialResult !== null &&
      data.officialResult.homeTeamUid !== null &&
      data.officialResult.awayTeamUid !== null
    ) {
      if (
        previousData === null ||
        previousData.officialResult.awayTeamUid !==
          data.officialResult.awayTeamUid ||
        previousData.officialResult.homeTeamUid !==
          data.officialResult.homeTeamUid
      ) {
        // Create the games, unless they already exist.
        // Get the two league teams first to get the real teamuids.
        // Then lookup the team itself.
        finalRet.push(
          Promise.all([
            db
              .collection("LeagueTeam")
              .document(data.officialResult.awayTeamUid)
              .get(),
            db
              .collection("LeagueTeam")
              .document(data.officialResult.homeTeamUid)
              .get()
          ])
            .then(teams => {
              var ret = [teams];
              if (teams[0].exists) {
                ret.push(
                  db
                    .collection("Games")
                    .where("sharedDataUid", "==", inputData.id)
                    .where("teamUid", "==", teams[0].id)
                    .get()
                );
              }
              if (teams[1].exists) {
                ret.push(
                  db
                    .collection("Games")
                    .where("sharedDataUid", "==", inputData.id)
                    .where("teamUid", "==", teams[1].id)
                    .get()
                );
              }
              return Promise.all(ret);
            })
            .then(games => {
              var foundHome = false;
              var foundAway = false;
              var homeDoc;
              var awayDoc;

              if (games[0][0].exists) {
                homeDoc = games[0][0];
              }
              if (games[0][1].exists) {
                awayDoc = games[0][1];
              }
              for (var i = 0; i < games[1].docs.length; i++) {
                for (var index in games[1].docs) {
                  var doc = games[1].docs[index];
                  if (
                    homeDoc !== null &&
                    doc.teamUid === homeDoc.data().teamUid
                  ) {
                    foundHome = true;
                  }
                  if (
                    awayDoc !== null &&
                    doc.teamUid === awayDoc.data().teamUid
                  ) {
                    foundAway = true;
                  }
                }
              }
              for (i = 0; i < games[2].docs.length; i++) {
                for (index in games[2].docs) {
                  doc = games[2].docs[index];
                  if (
                    homeDoc !== null &&
                    doc.teamUid === homeDoc.data().teamUid
                  ) {
                    foundHome = true;
                  }
                  if (
                    awayDoc !== null &&
                    doc.teamUid === awayDoc.data().teamUid
                  ) {
                    foundAway = true;
                  }
                }
              }
              // Create the new games.
              var ret = [];
              if (!foundHome) {
                ret.push(
                  createGame.createGameFromShared(inputData.after, homeDoc)
                );
              }
              if (!foundAway) {
                ret.push(
                  createGame.createGameFromShared(inputData.after, awayDoc)
                );
              }
              return Promise.all(ret);
            })
        );
      }
    }

    // Created with this, or updates with this result.
    if (
      data.officialResult !== null &&
      (data.officialResult.officialResult !== "OfficialResult.NotStarted" &&
        data.officialResult.officialResult !== "OfficialResult.InProgress" &&
        (previousData === null ||
          data.officialResult.officialResult !==
            previousData.officialResult.officialResult))
    ) {
      console.log(
        "Updating " +
          data.officialResult.awayTeamUid +
          " " +
          data.officialResult.homeTeamUid
      );
      var bits = [];
      bits.push(
        db
          .collection("GamesShared")
          .where("leagueDivisonUid", "==", data.leagueDivisonUid)
          .get()
          .then(snapshot => {
            console.log("Divison for ", data.leagueDivisonUid);
            // Adding up for away team and home team.
            var awayUid = data.officialResult.awayTeamUid;
            var homeUid = data.officialResult.homeTeamUid;
            var homeWin = 0;
            var homeLoss = 0;
            var homeTie = 0;
            var homePtDiff = 0;

            var awayWin = 0;
            var awayLoss = 0;
            var awayTie = 0;
            var awayPtDiff = 0;

            var tie = 0;
            for (var index in snapshot.docs) {
              var doc = snapshot.docs[index];
              // Only count games where these teams are involved.
              console.log(awayUid + " " + homeUid);
              if (
                doc.data().officialResult.homeTeamUid === homeUid ||
                doc.data().officialResult.homeTeamUid === awayUid
              ) {
                console.log("Home team!");
                //console.log(doc.data());
                var res = doc.data().officialResult.officialResult;
                var diff = 0;
                if (doc.data().officialResult.scores !== null) {
                  // Add up the scores.
                  for (var period in Object.keys(
                    doc.data().officialResult.scores
                  )) {
                    var perData = doc.data().officialResult.scores[period];
                    diff = perData.ptsFor - perData.ptsAgainst;
                  }
                }
                console.log(res);

                if (res === "OfficialResult.HomeTeamWon") {
                  if (doc.data().officialResult.homeTeamUid === homeUid) {
                    homeWin++;
                    homePtDiff += diff;
                  } else if (
                    doc.data().officialResult.homeTeamUid === awayUid
                  ) {
                    awayWin++;
                    awayPtDiff += diff;
                  }
                } else if (res === "OfficialResult.AwayTeamWon") {
                  if (doc.data().officialResult.homeTeamUid === homeUid) {
                    homeLoss++;
                    homePtDiff += diff;
                  } else if (
                    doc.data().officialResult.homeTeamUid === awayUid
                  ) {
                    awayLoss++;
                    awayPtDiff += diff;
                  }
                } else if (res === "OfficialResult.Tie") {
                  if (doc.data().officialResult.homeTeamUid === homeUid) {
                    homeTie++;
                  } else if (
                    doc.data().officialResult.homeTeamUid === awayUid
                  ) {
                    awayTie++;
                  }
                }
              }
              console.log(doc.data().officialResult.awayTeamUid);
              if (
                doc.data().officialResult.awayTeamUid === homeUid ||
                doc.data().officialResult.awayTeamUid === awayUid
              ) {
                console.log("Away team!");
                var diffAway = 0;
                if (doc.data().officialResult.scores !== null) {
                  // Add up the scores.
                  for (var innerPeriod in Object.keys(
                    doc.data().officialResult.scores
                  )) {
                    var innerPerData = doc.data().officialResult.scores[
                      innerPeriod
                    ];
                    diffAway = innerPerData.ptsFor - innerPerData.ptsAgainst;
                  }
                }
                res = doc.data().officialResult.officialResult;
                console.log(res);
                if (res === "OfficialResult.HomeTeamWon") {
                  if (doc.data().officialResult.awayTeamUid === homeUid) {
                    homeLoss++;
                    homePtDiff += diffAway;
                  } else if (
                    doc.data().officialResult.awayTeamUid === awayUid
                  ) {
                    awayLoss++;
                    awayPtDiff += diffAway;
                  }
                } else if (res === "OfficialResult.AwayTeamWon") {
                  if (doc.data().officialResult.awayTeamUid === homeUid) {
                    homeWin++;
                    homePtDiff += diffAway;
                  } else if (
                    doc.data().officialResult.awayTeamUid === awayUid
                  ) {
                    awayWin++;
                    awayPtDiff += diffAway;
                  }
                } else if (res === "OfficialResult.Tie") {
                  if (doc.data().officialResult.awayTeamUid === homeUid) {
                    homeTie++;
                  } else if (
                    doc.data().officialResult.awayTeamUid === awayUid
                  ) {
                    awayTie++;
                  }
                }
              }
            }
            var homeSnap = {};
            homeSnap["record." + data.leagueDivisonUid + ".win"] = homeWin;
            homeSnap["record." + data.leagueDivisonUid + ".tie"] = homeTie;
            homeSnap["record." + data.leagueDivisonUid + ".loss"] = homeLoss;
            homeSnap[
              "record." + data.leagueDivisonUid + ".pointDiff"
            ] = homePtDiff;
            var awaySnap = {};
            awaySnap["record." + data.leagueDivisonUid + ".win"] = awayWin;
            awaySnap["record." + data.leagueDivisonUid + ".tie"] = awayTie;
            awaySnap["record." + data.leagueDivisonUid + ".loss"] = awayLoss;
            awaySnap[
              "record." + data.leagueDivisonUid + ".pointDiff"
            ] = awayPtDiff;
            console.log(homeSnap);
            console.log(awaySnap);
            return Promise.all([
              db
                .collection("LeagueTeam")
                .doc(homeUid)
                .update(homeSnap),
              db
                .collection("LeagueTeam")
                .doc(awayUid)
                .update(awaySnap)
            ]);
          })
      );
      finalRet.push(Promise.all(bits));
    } else {
      console.log("Ignoring " + inputData.after.id);
    }

    return Promise.all(finalRet);
  });
