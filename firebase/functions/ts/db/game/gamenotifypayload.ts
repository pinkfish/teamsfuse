import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as fs from 'fs';

import { emailForGame, notifyForGame, PayloadData, ChangedData } from '../../util/notifyforgame';
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
            console.error('Invalid data');
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
        return;
    }

    // Check to see if there is any result at all yet or it is not a game.
    if (data.result === null || data.sharedData.type !== 'Game') {
        // No results.
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

    // Loop through the values on scores.
    let diff = false;
    if (previousData.result === null) {
        previousData.result = {
            scores: {},
        };
    }
    let ptsFor = 0;
    let ptsAgainst = 0;
    for (const s in data.result.scores) {
        if (data.result.scores.hasOwnProperty(s)) {
            const nowScore = data.result.scores[s];
            const beforeScore = previousData.result.scores[s];
            if (beforeScore === null || beforeScore === undefined) {
                diff = true;
            } else if (
                beforeScore.score.ptsAgainst !== nowScore.score.ptsAgainst ||
                beforeScore.score.ptsFor !== nowScore.score.ptsFor
            ) {
                diff = true;
            }
            ptsFor += nowScore.score.ptsFor;
            ptsAgainst += nowScore.score.ptsAgainst;
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
        let mess = '';
        if (data.result.inProgress === 'Final') {
            if (ptsFor > ptsAgainst) {
                mess = 'Won the game';
            } else if (ptsFor < ptsAgainst) {
                mess = 'Lost the game';
            } else {
                mess = 'Tied at end of game';
            }
        } else {
            let inProgress = '';
            if (data.result.period.startsWith('Overtime')) {
                inProgress = ' in overtime';
            } else if (data.result.period.startsWith('Penalty')) {
                inProgress = ' in penalty shootout';
            }
            if (ptsFor === ptsAgainst) {
                mess = 'Game tied' + inProgress;
            } else if (ptsFor > ptsAgainst) {
                mess = 'Winning game' + inProgress;
            } else {
                mess = 'Losing game' + inProgress;
            }
        }

        const payload: PayloadData = {
            title: '{{opponent.name}} ' + ptsFor + ' - ' + ptsAgainst,
            body: mess,
            click_action: 'GAMERESULT',
            tag: after.id + 'result',
        };

        const options: admin.messaging.MessagingOptions = {
            timeToLive: 259200,
            collapseKey: after.id + 'result',
        };

        try {
            await notifyForGame(after, payload, options, authUid, true, cache);
        } finally {
            cache.close();
        }
    }
    return;
}

export async function sendUpdateEmail(
    gameDoc: functions.firestore.DocumentSnapshot,
    fileName: string,
    subject: string,
    excludeUser: string,
    changedData: ChangedData,
    cache: DataNodeCache,
) {
    const data = gameDoc.data();
    if (data === null || data === undefined) {
        console.error('invalid data bits');
        return;
    }

    if (!fs.existsSync('lib/ts/templates/notify/' + fileName + '.txt')) {
        console.error('File ' + 'lib/ts/templates/notify/' + fileName + '.txt' + ' does not exist');
        return;
    }

    if (!fs.existsSync('lib/ts/templates/notify/' + fileName + '.html')) {
        console.error('File ' + 'lib/ts/templates/notify/' + fileName + '.html' + ' does not exist');
        return;
    }

    const payloadTxt = fs.readFileSync('lib/ts/templates/notify/' + fileName + '.txt', 'utf8');
    const payloadHtml = fs.readFileSync('lib/ts/templates/notify/' + fileName + '.html', 'utf8');
    return emailForGame(
        gameDoc,
        {
            from: 'noreply@email.teamsfuse.com',
            text: payloadTxt,
            body: payloadHtml,
            title: '[{{team.name}}] ' + subject,
            tag: 'email',
            click_action: 'openGame',
        },
        excludeUser,
        'emailOnUpdates',
        cache,
        changedData,
    );
}
