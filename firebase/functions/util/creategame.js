'use strict';

const admin = require('firebase-admin');

var db = admin.firestore();

exports.createGameFromShared = (sharedGameDoc, leagueTeamDoc) => {
    // Lookup the team details.
    return db.collection('Teams').document(leagueTeamDoc.teamUid).get().then(teamDoc => {
        // Setup the arrival time based on the team details.
        var arrivalTime = sharedGameDoc.data().time - (teamDoc.data().arrivalTime * 60 * 1000);
        var opponentUid = '';
        if (sharedGameDoc.officialResult.homeTeamUid == leagueTeamDoc.id) {
            opponentUid = sharedGameDoc.officialResult.awayTeamUid;
        } else {
            opponentUid = sharedGameDoc.officialResult.homeTeamUid;
        }
        var snap = {
            'notes': '',
            'arrivalTime': arrivalTime,
            // Don't create an opponent by default, team members can setup the mapping if they want.
            'opponentUid': '',
            'leagueOpponentUid': opponentLeagueTeamUid,
            'result': {
               'inProgress': 'GameInProgress.NotStarted',
               'result': 'GameResult.Unknown',
            },
            'seasonUid': leagueTeamDoc.data().seasonUid,
            'seriesId': '',
            'sharedDataUid': sharedGameUid,
            'teamUid': teamDoc.id,
            'uniform': '',
            'trackAttendance': teamDoc.data().trackAttendance,
        };

        return db.collection('Games').add(snap);
    });
}

exports.createOpponentForShared = (sharedGameUid, leagueTeamDoc, teamDoc, opponentTeamDoc) => {
    // Need to make opponents for the ones that don't exist.
    var opponents = db.collection('Teams').doc(teamDoc.id).collection('Opponents')
        .where('leagueTeamUid.' + leagueTeamDoc.id + '.added', '==', true)
        .get();

    return opponents.get().then(snapshot => {
        // Go through the opponents and match based on the ones that match the case
        // insensitive name.
        if (snapshot.docs.length === 0) {
            // Look at all the opponents and try that way.
            var opponents = db.collection('Teams').doc(teamDoc.id).collection('Opponents')
                .get();
            return Promises.all([null, opponents]);
        }
        return Promises.all([snapshot.docs[0].id]);
    }).then(opponentUpdate => {
        if (opponentUpdate[0] !== null) {
            return Promises.all([opponentUpdate]);
        }
        var compareName = leagueTeamDoc.data.name.toLowerCase().trim();
        for (doc in opponentUpdate.docs) {
            if (doc.data.name.toLowerCase().trim() === compareName) {
                // Found it!
                var index = 'leagueTeamUid.' + (leagueTeamDoc.id) + '.added';
                var newData = {}
                newData[index] = true;
                var update = db.collection('Teams').doc(teamDoc.id).collection('Opponents').doc(doc.id).update(
                    newData
                );
                return Promises.all([doc.id, update]);
            }
        }
        // Didn't find it, so make the opponent.
        newOpponentData = {
            'contact': '',
            'name': leagueTeamDoc.data.name,
            'leagueTeamUid': {

            }
        };
        newOpponentData['leagueTeamUid'][leagueTeamDoc.id] = { 'added': true, };
        return Promises.all([null, db.collection('Teams').doc(teamDoc.id).collection('Opponents')
            .add(newOpponentData)]);
    })
}