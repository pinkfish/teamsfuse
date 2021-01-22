import * as moment from 'moment-timezone';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import { notifyForGame, PayloadData } from '../../util/notifyforgame';

export async function notifyPayload(payload: PayloadData, snap: functions.firestore.DocumentSnapshot): Promise<void> {
    if (payload) {
        const data = snap.data();
        const nowTime = moment.utc();

        if (data === null || data === undefined) {
            console.log('Invalid data');
            return;
        }

        payload.body += ' for {{team.name}}';
        payload.body += ' located {{game.place.address}}';
        if (data.uniform !== '') {
            payload.body += ' wear {{game.uniform}}';
        }

        const gameTime = moment.utc(data.time).add(moment.duration({ hours: 3 }));
        const diffGameTime = gameTime.diff(nowTime, 'seconds');

        const options: admin.messaging.MessagingOptions = {
            timeToLive: diffGameTime * 1000,
            collapseKey: snap.id + 'change',
        };

        await notifyForGame(snap, payload, options, '', false);
    }
    return;
}
