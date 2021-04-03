import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import { notifyForGame, PayloadData } from '../../util/notifyforgame';
import { DataNodeCache } from '../../util/datacache';
import { DateTime, Duration } from 'luxon';

export async function notifyPayload(
    payload: PayloadData,
    snap: functions.firestore.DocumentSnapshot,
    cache: DataNodeCache,
): Promise<void> {
    if (payload) {
        const data = snap.data();
        const nowTime = DateTime.now().toUTC();

        if (data === null || data === undefined) {
            console.log('Invalid data');
            return;
        }

        const gameTime = DateTime.fromMillis(data.sharedData.time).plus(Duration.fromObject({ hours: 3 }));
        const diffGameTime = gameTime.diff(nowTime, 'seconds');

        const options: admin.messaging.MessagingOptions = {
            timeToLive: diffGameTime.seconds * 1000,
            collapseKey: snap.id + 'change',
        };

        try {
            await notifyForGame(snap, payload, options, '', false, cache);
        } finally {
            cache.close();
        }
    }
    return;
}

export async function notifyOfResults(
    after: functions.firestore.DocumentSnapshot,
    inputPrevious: { [field: string]: any } | undefined,
    cache: DataNodeCache,
    authUid: string,
) {
    const data = after.data();

    if (data === undefined || data === null) {
        console.log('Nothing to update');
        return;
    }

    // Check to see if there is any result at all yet.
    if (data.result === null) {
        // No results.
        console.log('No results');
        return data;
    }

    let previousData = inputPrevious;

    if (previousData === null || previousData === undefined) {
        previousData = {};
    }
    if (previousData.result === null || previousData.result === undefined) {
        previousData.result = {
            scores: {},
        };
    }

    console.log('Start ' + data.result.inProgress + ' ' + data.result.result + ' -- ' + previousData.result.result);
    // Loop through the values on scores.
    let diff = false;
    const diffScoreTypes = [];
    let curScores = data.result.scores['Regulation'];
    let result = 0;
    if (previousData.result === null) {
        previousData.result = {
            scores: {},
        };
    }
    if (curScores === null) {
        curScores = { ptsFor: 0, ptsAgainst: 0 };
    }
    //var currentScoreStr = '';
    for (const s in data.result.scores) {
        if (Object.prototype.hasOwnProperty.call(data.result.scores, s)) {
            const nowScore = data.result.scores[s];
            const beforeScore = previousData.result.scores[s];
            console.log(nowScore);
            console.log(s);
            console.log(beforeScore);
            if (beforeScore === null || typeof beforeScore === 'undefined') {
                diff = true;
                diffScoreTypes.push(s);
                //currentScoreStr = currentScoreStr + s + ' ' + ptsFor + ' - ' + ptsAgainst + '\n';
            } else if (beforeScore.ptsAgainst !== nowScore.ptsAgainst || beforeScore.ptsFor !== nowScore.ptsFor) {
                diff = true;
                diffScoreTypes.push(s);
                //currentScoreStr = currentScoreStr + s + ' ' + ptsFor + ' - ' + ptsAgainst + '\n';
            }
            if (nowScore.ptsFor > nowScore.ptsAgainst) {
                curScores = nowScore;
                result = 1;
            } else if (nowScore.ptsFor < nowScore.ptsAgainst) {
                curScores = nowScore;
                result = 2;
            }
        }
    }
    if (
        data.result.inProgress !== 'NotStarted' &&
        (data.result.inProgress !== previousData.result.inProgress ||
            diff ||
            data.result.result !== previousData.result.result)
    ) {
        // If we are authenticated then don't tell the person doing the
        // update about this change.
        console.log(data.result);
        console.log(curScores);
        let mess = '';
        if (data.result.inProgress === 'Final') {
            if (result === 0) {
                console.log(data.result);
                console.log(curScores);
                mess = 'Tied at end of game';
            } else if (result === 1) {
                mess = 'Won the game';
            } else {
                mess = 'Lost the game';
            }
        } else {
            let inProgress = '';
            if (data.result.period.startsWith('Overtime')) {
                inProgress = ' in overtime';
            } else if (data.result.period.startsWith('Penalty')) {
                inProgress = ' in penalty shootout';
            }
            if (result === 0) {
                mess = 'Game tied' + inProgress;
            } else if (result === 1) {
                mess = 'Winning game' + inProgress;
            } else {
                mess = 'Losing game' + inProgress;
            }
        }

        const payload: PayloadData = {
            title: '{{opponent.name}} ' + curScores.ptsFor + ' - ' + curScores.ptsAgainst,
            body: mess,
            click_action: 'GAMERESULT',
            tag: after.id + 'result',
        };

        const options: admin.messaging.MessagingOptions = {
            timeToLive: 259200,
            collapseKey: after.id + 'result',
        };

        console.log('Notifying about');
        console.log(payload);

        try {
            await notifyForGame(after, payload, options, authUid, true, cache);
        } finally {
            cache.close();
        }
    }
    return;
}
