import * as functions from 'firebase-functions';
import { notifyPayload } from './gamenotifypayload';
import { PayloadData } from '../../util/notifyforgame';
import { DateTime } from 'luxon';

export const notifyOnCreate = functions.firestore.document('/Games/{gameid}').onCreate((snap, context) => {
    const data = snap.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = DateTime.fromMillis(data.arrivalTime);
    const nowTime = DateTime.now().toUTC();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    console.log('on create ' + snap.id + ' diff ' + diff);
    if (diff.days <= 7 && nowTime.valueOf() < data.time) {
        console.log('Changed in here');
        // Notify the user of the new event/training/game.
        if (data.type === 'EventType.Practice') {
            payload = {
                title: 'New practice for {{team.name}}',
                body: 'New practice at {{arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.type === 'Game') {
            payload = {
                title: 'New Game vs {{opponent.name}}',
                body: 'New game at {{arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.type === 'Event') {
            payload = {
                title: 'New event for {{team.name}}',
                body: 'New event at {{arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        }
    }

    if (payload) {
        return notifyPayload(payload, snap);
    }
    return data;
});

export default notifyOnCreate;
