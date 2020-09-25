import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// Handle the creation case as well, so if we create a game
// with a specific result we update the team values.
export const onWrite = functions.firestore.document('/Games/{gameid}').onWrite(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before !== null ? inputData.before.data() : null;

    if (data === null || data === undefined) {
        console.log('no data at all');
        return;
    }
    if (previousData === null || previousData === undefined) {
        console.log('no data at all');
        return;
    }

    // Created with this, or updates with this result.
    if (
        data.result !== null &&
        data.result.inProgress === 'Final' &&
        (previousData === null ||
            data.result.inProgress !== previousData.result.inProgress ||
            data.result.result !== previousData.result.result)
    ) {
        console.log('Updating ' + data.teamUid);
        const snapshot = await db
            .collection('Games')
            .where('opponentUid', '==', data.opponentUid)
            .where('teamUid', '==', data.teamUid)
            .where('result.inProgress', '==', 'Final')
            .get();
        console.log('Team for season', data.seasonUid);
        let loss = 0;
        let win = 0;
        let tie = 0;
        snapshot.docs.forEach((doc) => {
            const res = doc.data().result.result;
            if (res === 'Win') {
                win++;
            }
            if (res === 'Loss') {
                loss++;
            }
            if (res === 'Tie') {
                tie++;
            }
        });
        const snap: { [name: string]: any } = {};
        snap['seasons.' + data.seasonUid + '.win'] = win;
        snap['seasons.' + data.seasonUid + '.tie'] = tie;
        snap['seasons.' + data.seasonUid + '.loss'] = loss;
        console.log(snap);
        await db.collection('Teams').doc(data.teamUid).collection('Opponents').doc(data.opponentUid).update(snap);

        const snappy = await db
            .collection('Games')
            .where('seasonUid', '==', data.seasonUid)
            .where('teamUid', '==', data.teamUid)
            .where('result.inProgress', '==', 'Final')
            .get();
        console.log('For season', data.seasonUid);
        loss = 0;
        win = 0;
        tie = 0;
        snappy.docs.forEach((doc) => {
            const res = doc.data().result.result;
            if (res === 'Win') {
                win++;
            }
            if (res === 'Loss') {
                loss++;
            }
            if (res === 'Tie') {
                tie++;
            }
        });
        const snap2: { [name: string]: any } = {};
        snap2['record.win'] = win;
        snap2['record.tie'] = tie;
        snap2['record.loss'] = loss;
        console.log(snap2);
        await db.collection('Seasons').doc(data.seasonUid).update(snap2);
    } else {
        console.log('Igorning ' + data.result.inProgress + ' ' + data.result.result);
    }
    return;
});
