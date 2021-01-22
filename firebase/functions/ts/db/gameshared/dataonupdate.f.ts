import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { createGameFromShared } from '../../util/creategame';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onWrite = functions.firestore.document('/GamesShared/{gameid}').onWrite(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before !== null && inputData.before !== undefined ? inputData.before.data() : null;

    if (data === null || data === undefined) {
        console.error('Data stuff incorrect');
        return;
    }

    if (previousData === undefined) {
        console.error('Update the previous thig');
        return;
    }

    const snapshot = await db.collection('Games').where('sharedDataUid', '==', inputData.after.id).get();
    if (snapshot.empty) {
        console.log('No matching games?');
        return;
    }

    for (const idx in snapshot.docs) {
        const doc = snapshot.docs[idx];
        // Update the data in the doc.
        await db.collection('Games').doc(doc.id).update({
            sharedData: data,
        });
    }

    // If the team is setup, then we need to go and do a bunch of work to connect the
    // shared games to the real time.
    if (
        data.officialResult !== null &&
        data.officialResult.homeTeamUid !== null &&
        data.officialResult.awayTeamUid !== null
    ) {
        if (
            previousData === null ||
            previousData.officialResult.awayTeamUid !== data.officialResult.awayTeamUid ||
            previousData.officialResult.homeTeamUid !== data.officialResult.homeTeamUid
        ) {
            // Create the games, unless they already exist.
            // Get the two league teams first to get the real teamuids.
            // Then lookup the team itself.
            const awayTeam = await db.collection('LeagueTeam').doc(data.officialResult.awayTeamUid).get();
            const homeTeam = await db.collection('LeagueTeam').doc(data.officialResult.homeTeamUid).get();
            let gamesAway: admin.firestore.QuerySnapshot | null = null;
            if (awayTeam.exists) {
                gamesAway = await db
                    .collection('Games')
                    .where('sharedDataUid', '==', inputData.after.id)
                    .where('teamUid', '==', awayTeam.id)
                    .get();
            }
            let gamesHome: admin.firestore.QuerySnapshot | null = null;
            if (homeTeam.exists) {
                gamesHome = await db
                    .collection('Games')
                    .where('sharedDataUid', '==', inputData.after.id)
                    .where('teamUid', '==', homeTeam.id)
                    .get();
            }

            let foundHome = false;
            let foundAway = false;
            if (gamesAway !== null) {
                for (const i in gamesAway.docs) {
                    const doc = gamesAway.docs[i];
                    const docData = doc.data();
                    if (homeTeam.exists && docData?.teamUid === homeTeam.data()?.teamUid) {
                        foundHome = true;
                    }
                    if (awayTeam.exists && docData?.teamUid === awayTeam.data()?.teamUid) {
                        foundAway = true;
                    }
                }
            }
            if (gamesHome !== null) {
                for (const i in gamesHome.docs) {
                    const doc = gamesHome.docs[i];
                    const docData = doc.data();
                    if (homeTeam.exists && docData?.teamUid === homeTeam.data()?.teamUid) {
                        foundHome = true;
                    }
                    if (awayTeam.exists && docData?.teamUid === awayTeam.data()?.teamUid) {
                        foundAway = true;
                    }
                }
            }

            // Create the new games.
            if (!foundHome) {
                await createGameFromShared(inputData.after, homeTeam);
            }
            if (!foundAway) {
                await createGameFromShared(inputData.after, awayTeam);
            }
        }
    }

    // Created with this, or updates with this result.
    if (
        data.officialResult !== null &&
        data.officialResult.officialResult !== 'NotStarted' &&
        data.officialResult.officialResult !== 'InProgress' &&
        (previousData === null || data.officialResult.officialResult !== previousData.officialResult.officialResult)
    ) {
        console.log('Updating ' + data.officialResult.awayTeamUid + ' ' + data.officialResult.homeTeamUid);
        const snappy = await db.collection('GamesShared').where('leagueDivisonUid', '==', data.leagueDivisonUid).get();
        console.log('Divison for ', data.leagueDivisonUid);
        // Adding up for away team and home team.
        const awayUid = data.officialResult.awayTeamUid;
        const homeUid = data.officialResult.homeTeamUid;
        let homeWin = 0;
        let homeLoss = 0;
        let homeTie = 0;
        let homePtDiff = 0;

        let awayWin = 0;
        let awayLoss = 0;
        let awayTie = 0;
        let awayPtDiff = 0;

        for (const index in snappy.docs) {
            const doc = snappy.docs[index];
            // Only count games where these teams are involved.
            console.log(awayUid + ' ' + homeUid);
            const docData = doc.data();
            if (docData === null || docData === undefined) {
                console.error('doc data');
                continue;
            }
            if (docData.officialResult.homeTeamUid === homeUid || docData.officialResult.homeTeamUid === awayUid) {
                console.log('Home team!');
                //console.log(doc.data());
                const res = docData.officialResult.officialResult;
                let diff = 0;
                if (docData.officialResult.scores !== null) {
                    // Add up the scores.
                    for (const period in Object.keys(docData.officialResult.scores)) {
                        const perData = docData.officialResult.scores[period];
                        diff = perData.ptsFor - perData.ptsAgainst;
                    }
                }
                console.log(res);

                if (res === 'HomeTeamWon') {
                    if (docData.officialResult.homeTeamUid === homeUid) {
                        homeWin++;
                        homePtDiff += diff;
                    } else if (docData.officialResult.homeTeamUid === awayUid) {
                        awayWin++;
                        awayPtDiff += diff;
                    }
                } else if (res === 'AwayTeamWon') {
                    if (docData.officialResult.homeTeamUid === homeUid) {
                        homeLoss++;
                        homePtDiff += diff;
                    } else if (docData.officialResult.homeTeamUid === awayUid) {
                        awayLoss++;
                        awayPtDiff += diff;
                    }
                } else if (res === 'Tie') {
                    if (docData.officialResult.homeTeamUid === homeUid) {
                        homeTie++;
                    } else if (docData.officialResult.homeTeamUid === awayUid) {
                        awayTie++;
                    }
                }
            }
            console.log(docData.officialResult.awayTeamUid);
            if (docData.officialResult.awayTeamUid === homeUid || docData.officialResult.awayTeamUid === awayUid) {
                console.log('Away team!');
                let diffAway = 0;
                if (docData.officialResult.scores !== null) {
                    // Add up the scores.
                    for (const innerPeriod in Object.keys(docData.officialResult.scores)) {
                        const innerPerData = docData.officialResult.scores[innerPeriod];
                        diffAway = innerPerData.ptsFor - innerPerData.ptsAgainst;
                    }
                }
                const res = docData.officialResult.officialResult;
                console.log(res);
                if (res === 'HomeTeamWon') {
                    if (docData.officialResult.awayTeamUid === homeUid) {
                        homeLoss++;
                        homePtDiff += diffAway;
                    } else if (docData.officialResult.awayTeamUid === awayUid) {
                        awayLoss++;
                        awayPtDiff += diffAway;
                    }
                } else if (res === 'AwayTeamWon') {
                    if (docData.officialResult.awayTeamUid === homeUid) {
                        homeWin++;
                        homePtDiff += diffAway;
                    } else if (docData.officialResult.awayTeamUid === awayUid) {
                        awayWin++;
                        awayPtDiff += diffAway;
                    }
                } else if (res === 'Tie') {
                    if (docData.officialResult.awayTeamUid === homeUid) {
                        homeTie++;
                    } else if (docData.officialResult.awayTeamUid === awayUid) {
                        awayTie++;
                    }
                }
            }
        }
        const homeSnap: { [name: string]: any } = {};
        homeSnap['record.' + data.leagueDivisonUid + '.win'] = homeWin;
        homeSnap['record.' + data.leagueDivisonUid + '.tie'] = homeTie;
        homeSnap['record.' + data.leagueDivisonUid + '.loss'] = homeLoss;
        homeSnap['record.' + data.leagueDivisonUid + '.pointDiff'] = homePtDiff;
        const awaySnap: { [name: string]: any } = {};
        awaySnap['record.' + data.leagueDivisonUid + '.win'] = awayWin;
        awaySnap['record.' + data.leagueDivisonUid + '.tie'] = awayTie;
        awaySnap['record.' + data.leagueDivisonUid + '.loss'] = awayLoss;
        awaySnap['record.' + data.leagueDivisonUid + '.pointDiff'] = awayPtDiff;
        console.log(homeSnap);
        console.log(awaySnap);
        await db.collection('LeagueTeam').doc(homeUid).update(homeSnap);
        await db.collection('LeagueTeam').doc(awayUid).update(awaySnap);
    } else {
        console.log('Ignoring ' + inputData.after.id);
    }

    return;
});

export default onWrite;
