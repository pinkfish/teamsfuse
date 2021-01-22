import * as admin from 'firebase-admin';

const db = admin.firestore();

export async function updateTeam(teamUid: string, seasonUid: string, opponentUid: string): Promise<void> {
    await updateTeamOpponent(teamUid, seasonUid, opponentUid);
    return updateTeamSeason(teamUid, seasonUid, opponentUid);
}

async function updateTeamOpponent(teamUid: string, seasonUid: string, opponentUid: string): Promise<void> {
    console.log('Updating ' + teamUid);
    const snapshot = await db
        .collection('Games')
        .where('opponentUid', '==', opponentUid)
        .where('teamUid', '==', teamUid)
        .where('seasonUid', '==', seasonUid)
        .where('result.inProgress', '==', 'Final')
        .get();
    console.log('Team for season', seasonUid);
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
    snap['seasons.' + seasonUid + '.win'] = win;
    snap['seasons.' + seasonUid + '.tie'] = tie;
    snap['seasons.' + seasonUid + '.loss'] = loss;
    console.log(snap);
    await db.collection('Teams').doc(teamUid).collection('Opponents').doc(opponentUid).update(snap);
    return;
}

async function updateTeamSeason(teamUid: string, seasonUid: string, opponentUid: string): Promise<void> {
    const snappy = await db
        .collection('Games')
        .where('seasonUid', '==', seasonUid)
        .where('teamUid', '==', teamUid)
        .where('result.inProgress', '==', 'Final')
        .get();
    console.log('For season', seasonUid);
    let loss = 0;
    let win = 0;
    let tie = 0;
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
    await db.collection('Seasons').doc(seasonUid).update(snap2);
    return;
}
