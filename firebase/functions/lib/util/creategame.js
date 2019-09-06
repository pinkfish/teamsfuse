'use strict';

const admin = require('firebase-admin');

const db = admin.firestore();

exports.createGameFromShared = (sharedGameDoc, leagueTeamDoc) => {
    // Lookup the team details.
    return Promises.all(
        [
            db
                .collection('Teams')
                .document(leagueTeamDoc.teamUid)
                .get(),
            db
                .collection('Teams')
                .document(leagueTeamDoc.teamUid)
                .collection('Opponents'),
        ].then(stuff => {
            const teamDoc = stuff[0];
            const opponents = stuff[1];
            // Setup the arrival time based on the team details.
            const arrivalTime = sharedGameDoc.data().time - teamDoc.data().arrivalTime * 60 * 1000;
            let opponentLeagueUid = '';
            if (sharedGameDoc.officialResult.homeTeamUid === leagueTeamDoc.id) {
                opponentLeagueUid = sharedGameDoc.officialResult.awayTeamUid;
            } else {
                opponentLeagueUid = sharedGameDoc.officialResult.homeTeamUid;
            }
            // See if we need to create an opponent and connect this up.
            let opponentUid;
            let opponentNameUid;
            const compareName = leagueTeamDoc
                .data()
                .name.trim()
                .toLowerCase();
            if (opponents.docs.length === 0) {
                // Look at all the opponents and see what we can do.
                for (const doc in opponents.docs) {
                    if (doc.leagueTeamUid === leagueTeamDoc.id) {
                        // This is us.
                        opponentUid = doc.id;
                    }
                    if (
                        doc
                            .data()
                            .name.trim()
                            .toLowerCase() === compareName
                    ) {
                        opponentNameUid = doc.id;
                    }
                }
            }
            if (opponentUid === null) {
                opponentUid = opponentNameUid;
            }
            let ret;
            if (opponentUid === null) {
                const newOpponent = {
                    name: leagueTeamDoc.name,
                    contact: '',
                    leagueTeamUid: {},
                };
                newOpponent['leagueTeamUid'][leagueTeamDoc.id] = { added: true };
                ret = [
                    db
                        .collection('Teams')
                        .document(eagueTeamDoc.teamUid)
                        .collection('Opponents')
                        .add(newOpponent),
                    null,
                ];
            } else {
                ret = [null, opponentUid];
            }
            return Promises.all(ret);
        }),
    ).then(snap => {
        let opponentUid = snap[1];
        if (snap[0] !== null) {
            opponentUid = snap[0].id;
        }
        const newGame = {
            notes: '',
            arrivalTime: arrivalTime,
            // Don't create an opponent by default, team members can setup the mapping if they want.
            opponentUid: opponentUid,
            leagueOpponentUid: opponentLeagueUid,
            result: {
                inProgress: 'GameInProgress.NotStarted',
                result: 'GameResult.Unknown',
            },
            seasonUid: leagueTeamDoc.data().seasonUid,
            seriesId: '',
            sharedDataUid: sharedGameUid,
            teamUid: teamDoc.id,
            uniform: '',
            trackAttendance: teamDoc.data().trackAttendance,
        };

        return db.collection('Games').add(newGame);
    });
};

exports.createOpponentForShared = (sharedGameUid, leagueTeamDoc, teamDoc, opponentTeamDoc) => {
    // Need to make opponents for the ones that don't exist.
    const opponents = db
        .collection('Teams')
        .doc(teamDoc.id)
        .collection('Opponents')
        .where('leagueTeamUid.' + leagueTeamDoc.id + '.added', '==', true);

    return opponents
        .get()
        .then(snapshot => {
            // Go through the opponents and match based on the ones that match the case
            // insensitive name.
            if (snapshot.docs.length === 0) {
                // Look at all the opponents and try that way.
                const opponents = db
                    .collection('Teams')
                    .doc(teamDoc.id)
                    .collection('Opponents')
                    .get();
                return Promises.all([null, opponents]);
            }
            return Promises.all([snapshot.docs[0].id]);
        })
        .then(opponentUpdate => {
            if (opponentUpdate[0] !== null) {
                return Promises.all([opponentUpdate]);
            }
            const compareName = leagueTeamDoc.data.name.toLowerCase().trim();
            for (doc in opponentUpdate.docs) {
                if (doc.data.name.toLowerCase().trim() === compareName) {
                    // Found it!
                    const index = 'leagueTeamUid.' + leagueTeamDoc.id + '.added';
                    const newData = {};
                    newData[index] = true;
                    const update = db
                        .collection('Teams')
                        .doc(teamDoc.id)
                        .collection('Opponents')
                        .doc(doc.id)
                        .update(newData);
                    return Promises.all([doc.id, update]);
                }
            }
            // Didn't find it, so make the opponent.
            newOpponentData = {
                contact: '',
                name: leagueTeamDoc.data.name,
                leagueTeamUid: {},
            };
            newOpponentData['leagueTeamUid'][leagueTeamDoc.id] = { added: true };
            return Promises.all([
                null,
                db
                    .collection('Teams')
                    .doc(teamDoc.id)
                    .collection('Opponents')
                    .add(newOpponentData),
            ]);
        });
};