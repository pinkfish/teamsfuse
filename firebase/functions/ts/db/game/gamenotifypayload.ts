import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import { notifyForGame, PayloadData } from '../../util/notifyforgame';
import { DataNodeCache } from '../../util/datacache';
import { DateTime, Duration } from 'luxon';

export async function notifyPayload(payload: PayloadData, snap: functions.firestore.DocumentSnapshot): Promise<void> {
    if (payload) {
        const data = snap.data();
        const nowTime = DateTime.now().toUTC();

        if (data === null || data === undefined) {
            console.log('Invalid data');
            return;
        }

        payload.body += ' for {{team.name}}';
        payload.body += ' located {{game.place.address}}';
        if (data.uniform !== '') {
            payload.body += ' wear {{game.uniform}}';
        }

        const gameTime = DateTime.fromMillis(data.sharedData.time).plus(Duration.fromObject({ hours: 3 }));
        const diffGameTime = gameTime.diff(nowTime, 'seconds');

        const options: admin.messaging.MessagingOptions = {
            timeToLive: diffGameTime.seconds * 1000,
            collapseKey: snap.id + 'change',
        };

        const cache = new DataNodeCache();
        try {
            await notifyForGame(snap, payload, options, '', false, cache);
        } finally {
            cache.close();
        }
    }
    return;
}
