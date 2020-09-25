import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as moment from 'moment';
import { notifyForGame, PayloadData } from '../util/notifyforgame';

const db = admin.firestore();

// 2 hours.
const CUT_OFF_DURATION = moment.duration({ hours: 2 });
const LOOK_AHEAD_DURATION = moment.duration({ hours: 2 });

export const onPublish = functions.pubsub.topic('hourly-tick').onPublish(async (data, context) => {
    console.log('Doing the hours work.');

    // Do something useful every hour.
    const now = moment().add(LOOK_AHEAD_DURATION);
    const cutoff = moment().subtract(CUT_OFF_DURATION);
    const snapshot = await db
        .collection('Games')
        .where('arrivalTime', '>', cutoff.valueOf())
        .where('arrivalTime', '<', now.valueOf())
        .get();
    for (const index in snapshot.docs) {
        if (Object.prototype.hasOwnProperty.call(snapshot.docs, index)) {
            const doc = snapshot.docs[index];
            console.log('Processing game ' + doc.id);
            if (doc.data().notifiedHour) {
                console.log('Already notified about ' + doc.id);
                continue;
            }
            const docData = doc.data();
            if (docData === null || docData === undefined) {
                continue;
            }
            // Get the shared data for the game too.
            const sharedGame = await db.collection('GamesShared').doc(doc.data().sharedDataUid).get();
            // Send notification to users, get all the players.
            // Get all the players users.
            // Send notifications.
            const timeToLive = 7200;
            const sharedGameData = sharedGame.data();
            if (sharedGameData === null || sharedGameData === undefined) {
                console.log('Already notified about ' + doc.id);
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
            if (sharedGameData.type === 'EventType.Practice') {
                message.title = 'Practice for {{team.name}}';
                message.body = 'Starting at {{arrivalTime}} to {{endTime}}';
            } else if (sharedGameData.type === 'EventType.Game') {
                message.title = 'Game vs {{opponent.name}} for {{team.name}}';
                message.body = 'Arrive by {{arrivalTime}}, game at {{gameTime}}';
            } else if (sharedGameData.type === 'EventType.Event') {
                message.title = 'Event for {{team.name}}';
                message.body = 'Arrive by {{arrivalTime}}';
            }
            if (message.body === undefined || message.body === null) {
                console.log('no body, droping out.');
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
                console.log(payload);

                await notifyForGame(doc, payload, message, '', false);
            }
        } else {
            console.log('Already notified for index ' + index);
        }
    }
});
