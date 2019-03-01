'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');

var db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
exports = module.exports = functions.firestore.document("/Games/{gameid}")
    .onWrite((inputData, context) => {
        const data = inputData.after.data();
        const previousData = inputData.before !== null
            ? inputData.before.data()
            : null;

        // Created with this, or updates with this result.
        if (data.result !== null &&
            (data.result.inProgress === "GameInProgress.Final" &&
            (previousData === null ||
            data.result.inProgress !== previousData.result.inProgress ||
            data.result.result !== previousData.result.result))) {
            console.log('Updating ' + data.teamUid);
            var bits = [];
            bits.push(db.collection('Games')
                .where("opponentUid", '==', data.opponentUid)
                .where("teamUid", "==", data.teamUid)
                .where("result.inProgress", '==', "GameInProgress.Final")
                .get().then(snapshot => {
                    console.log('Team for season', data.seasonUid);
                    var loss = 0
                    var win = 0
                    var tie = 0
                    snapshot.docs.forEach(doc => {
                        var res = doc.data().result.result
                        if (res === "GameResult.Win") {
                            win++;
                        }
                        if (res === "GameResult.Loss") {
                            loss++;
                        }
                        if (res === "GameResult.Tie") {
                            tie++;
                        }
                    })
                    snap = {}
                    snap['seasons.' + data.seasonUid + '.win'] = win
                    snap['seasons.' + data.seasonUid + '.tie'] = tie
                    snap['seasons.' + data.seasonUid + '.loss'] = loss
                    console.log(snap);
                    return db.collection("Teams").doc(data.teamUid).collection('Opponents')
                        .doc(data.opponentUid)
                        .update(snap)
                }));
            bits.push(inputData.after.ref.parent.parent.collection('Games')
                .where("seasonUid", '==', data.seasonUid)
                .where("teamUid", "==", data.teamUid)
                .where("result.inProgress", '==', "GameInProgress.Final")
                .get().then(snapshot => {
                    console.log('For season', data.seasonUid);
                    var loss = 0
                    var win = 0
                    var tie = 0
                    snapshot.docs.forEach(doc => {
                        var res = doc.data().result.result
                        if (res === "GameResult.Win") {
                            win++;
                        }
                        if (res === "GameResult.Loss") {
                            loss++;
                        }
                        if (res === "GameResult.Tie") {
                            tie++;
                        }
                    })
                    snap = {}
                    snap['record.win'] = win
                    snap['record.tie'] = tie
                    snap['record.loss'] = loss
                    console.log(snap);
                    return db.collection('Seasons').doc(data.seasonUid)
                        .update(snap)
                }))
            return Promise.all(bits)
        } else {
            console.log("Igorning " + data.result.inProgress + " " + data.result.result);
        }
        return data;
    });