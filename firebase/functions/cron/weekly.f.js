'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const settings = {timestampsInSnapshots: true};

var db = admin.firestore();

// 8 days.
const CUT_OFF_TIME = 8 * 24 * 60 * 60 * 1000;

exports = module.exports =
    functions.pubsub.topic('weekly-tick').onPublish((data, context) => {
        // Do something useful every week.
        console.log('Doing the weeks work.');

        return db.collection("Games")
             .where("result.inProgress", '==', "GameInProgress.Final")
             .get()
             .then(snapshot => {
                 var promises = []
                 var scores = {}
                 snapshot.docs.forEach(doc => {
                     if (!(doc.data().teamUid in scores)) {
                         scores[doc.data().teamUid] = { seasons: {} }
                     }
                     var teamScores = scores[doc.data().teamUid];
                     if (!(doc.data().seasonUid in teamScores.seasons)) {
                         teamScores.seasons[doc.data().seasonUid] = { win: 0, loss: 0, tie: 0, opponents: {} }
                     }
                     var seasonScores = teamScores.seasons[doc.data().seasonUid];
                     if (!(doc.data().opponentUid in seasonScores.opponents)) {
                         seasonScores.opponents[doc.data().opponentUid] = { win: 0, loss: 0, tie: 0 }
                     }
                     var res = doc.data().result.result
                     if (res === "GameResult.Win") {
                         seasonScores.win++;
                         seasonScores.opponents[doc.data().opponentUid].win++;
                     }
                     if (res === "GameResult.Loss") {
                         seasonScores.loss++;
                         seasonScores.opponents[doc.data().opponentUid].loss++;
                     }
                     if (res === "GameResult.Tie") {
                         seasonScores.tie++;
                         seasonScores.opponents[doc.data().opponentUid].tie++;
                     }
                 });
                 // Loop through the scores and update the results.
                 for (var teamUid in scores) {
                     if (scores.hasOwnProperty(teamUid)) {
                         var teamScores = scores[teamUid];
                         console.log(teamScores);
                         for (var seasonUid in teamScores.seasons) {
                             if (teamScores.seasons.hasOwnProperty(seasonUid)) {
                                 var seasonScores = teamScores.seasons[seasonUid];
                                 // Update the value.
                                 var snap = {}
                                 snap['record.win'] = seasonScores.win
                                 snap['record.tie'] = seasonScores.tie
                                 snap['record.loss'] = seasonScores.loss
                                 promises.push(db.collection('Seasons').doc(seasonUid)
                                     .update(snap))

                                 for (var opponentUid in seasonScores.opponents) {
                                     if (seasonScores.opponents.hasOwnProperty(opponentUid)) {
                                         var opponentScores = seasonScores.opponents[opponentUid];
                                         // Update the value.
                                         snap = {}
                                         snap['seasons.' + seasonUid + '.win'] = opponentScores.win
                                         snap['seasons.' + seasonUid + '.tie'] = opponentScores.tie
                                         snap['seasons.' + seasonUid + '.loss'] = opponentScores.loss
                                         promises.push(db.collection("Teams").doc(teamUid).collection('Opponents')
                                               .doc(opponentUid)
                                               .update(snap))
                                     }
                                 }
                             }
                         }
                     }
                 }
                 return Promise.all(promises);
             })
    });