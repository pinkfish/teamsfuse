import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DateTime, Duration } from 'luxon';
import { notifyForGame, PayloadData } from '../util/notifyforgame';
import { DataNodeCache } from '../util/datacache';

const db = admin.firestore();

// 2 hours.
const CUT_OFF_DURATION = Duration.fromObject({ hours: 2 });
const LOOK_AHEAD_DURATION = Duration.fromObject({ hours: 2 });

export const onHourlyPublish = functions.pubsub.topic('hourly-tick').onPublish(async (data, context) => {
    // Do something useful every hour.
    const now = DateTime.now().toUTC().plus(LOOK_AHEAD_DURATION);
    const cutoff = DateTime.now().toUTC().minus(CUT_OFF_DURATION);
    const snapshot = await db
        .collection('Games')
        .where('arrivalTime', '>', cutoff.valueOf())
        .where('arrivalTime', '<', now.valueOf())
        .get();
    const cache = new DataNodeCache();
    try {
        for (const index in snapshot.docs) {
            if (Object.prototype.hasOwnProperty.call(snapshot.docs, index)) {
                const doc = snapshot.docs[index];
                if (doc.data().notifiedHour) {
                    continue;
                }
                const docData = doc.data();
                if (docData === null || docData === undefined) {
                    continue;
                }
                // Get the shared data for the game too.
                // Send notification to users, get all the players.
                // Get all the players users.
                // Send notifications.
                const timeToLive = 7200;
                const sharedGameData = docData.sharedData;
                if (sharedGameData === null || sharedGameData === undefined) {
                    console.error('Cannot find shared data ' + doc.id);
                    continue;
                }
                const message: admin.messaging.MessagingOptions = {
                    timeToLive: timeToLive,
                    collapseKey: doc.id,
                };
                const payload: PayloadData = {
                    ts: docData.arrivalTime,
                    k: doc.id,
                    a: sharedGameData.place.address,
                    p: sharedGameData.place.placeId,
                    click_action: 'GAME',
                    tag: doc.id,
                    title: '',
                    body: '',
                };
                if (sharedGameData.type === 'Practice') {
                    message.title = 'Practice for {{team.name}}';
                    message.body = 'Starting at {{arrivalTime}} to {{endTime}}';
                } else if (sharedGameData.type === 'Game') {
                    message.title = 'Game vs {{opponent.name}} for {{team.name}}';
                    message.body = 'Arrive by {{arrivalTime}}, game at {{gameTime}}';
                } else if (sharedGameData.type === 'Event') {
                    message.title = 'Event for {{team.name}}';
                    message.body = 'Arrive by {{arrivalTime}}';
                }
                if (message.body === undefined || message.body === null) {
                    console.error('no body, dropping out.');
                    continue;
                }
                message.body += ' for {{team.name}}';
                message.body += ' located {{game.place.address}}';
                if (docData.uniform !== '') {
                    message.body += ' wear {{game.uniform}}';
                }

                if (sharedGameData.place !== null) {
                    payload.a = sharedGameData.place.address;
                    payload.p = sharedGameData.place.placeId;
                }

                if (payload) {
                    await notifyForGame(doc, payload, message, '', false, cache);
                }
            }
        }
    } finally {
        cache.close();
    }
});

export default onHourlyPublish;
