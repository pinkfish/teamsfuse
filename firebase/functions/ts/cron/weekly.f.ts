import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface OpponentData {
    win: number;
    loss: number;
    tie: number;
}

interface SeasonDataStuff {
    win: number;
    loss: number;
    tie: number;
    opponents: { [name: string]: OpponentData };
}

interface TeamData {
    seasons: { [name: string]: SeasonDataStuff };
}

interface MainData {
    [name: string]: TeamData;
}

export const onPublish = functions.pubsub.topic('weekly-tick').onPublish(async (data, context) => {
    // Do something useful every week.
    console.log('Doing the weeks work.');

    const snapshot = await db.collection('Games').where('result.inProgress', '==', 'GameInProgress.Final').get();
    const scores: MainData = {};
    for (const id in snapshot.docs) {
        const doc = snapshot.docs[id];
        if (!(doc.data().teamUid in scores)) {
            scores[doc.data().teamUid] = { seasons: {} };
        }
        const teamScores = scores[doc.data().teamUid];
        if (!(doc.data().seasonUid in teamScores.seasons)) {
            teamScores.seasons[doc.data().seasonUid] = {
                win: 0,
                loss: 0,
                tie: 0,
                opponents: {},
            };
        }
        const seasonScores = teamScores.seasons[doc.data().seasonUid];
        if (!(doc.data().opponentUid in seasonScores.opponents)) {
            seasonScores.opponents[doc.data().opponentUid] = {
                win: 0,
                loss: 0,
                tie: 0,
            };
        }
        const res = doc.data().result.result;
        if (res === 'Win') {
            seasonScores.win++;
            seasonScores.opponents[doc.data().opponentUid].win++;
        }
        if (res === 'Loss') {
            seasonScores.loss++;
            seasonScores.opponents[doc.data().opponentUid].loss++;
        }
        if (res === 'Tie') {
            seasonScores.tie++;
            seasonScores.opponents[doc.data().opponentUid].tie++;
        }
    }
    // Loop through the scores and update the results.
    for (const teamUid in scores) {
        if (Object.prototype.hasOwnProperty.call(scores, teamUid)) {
            const teamScores = scores[teamUid];
            console.log(teamScores);
            for (const seasonUid in teamScores.seasons) {
                if (Object.prototype.hasOwnProperty.call(teamScores.seasons, seasonUid)) {
                    const seasonScores = teamScores.seasons[seasonUid];
                    // Update the value.
                    let snap: { [name: string]: any } = {};
                    snap['record.win'] = seasonScores.win;
                    snap['record.tie'] = seasonScores.tie;
                    snap['record.loss'] = seasonScores.loss;
                    await db.collection('Seasons').doc(seasonUid).update(snap);

                    for (const opponentUid in seasonScores.opponents) {
                        if (Object.prototype.hasOwnProperty.call(seasonScores.opponents, opponentUid)) {
                            const opponentScores = seasonScores.opponents[opponentUid];
                            // Update the value.
                            snap = {};
                            snap['seasons.' + seasonUid + '.win'] = opponentScores.win;
                            snap['seasons.' + seasonUid + '.tie'] = opponentScores.tie;
                            snap['seasons.' + seasonUid + '.loss'] = opponentScores.loss;
                            await db
                                .collection('Teams')
                                .doc(teamUid)
                                .collection('Opponents')
                                .doc(opponentUid)
                                .update(snap);
                        }
                    }
                }
            }
        }
    }
});

export default onPublish;
