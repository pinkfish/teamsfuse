import * as functions from 'firebase-functions';
import { notifyPayload } from './gamenotifypayload';
import * as moment from 'moment';
import { PayloadData } from '../../util/notifyforgame';

export const onDelete = functions.firestore.document('/Games/{gameid}').onDelete(async (snap, context) => {
    const data = snap.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = moment(data.arrivalTime);
    const nowTime = moment();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    console.log('on change ' + snap.id + ' diff ' + diff);
    if (diff <= 7 && nowTime.valueOf() < data.time) {
        console.log('Changed in here');
        // Notify the user of the new event/training/game.
        if (data.type === 'Practice') {
            payload = {
                title: 'CANCELLED practice for {{team.name}}',
                body: 'Cancelled practice at {[arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.type === 'Game') {
            payload = {
                title: 'CANCELLED Game vs {{opponent.name}}',
                body: 'Cancelled game at {{arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.type === 'EventType.Event') {
            payload = {
                title: 'DELETE event for {{team.name}}',
                body: 'Delete event at {{arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        }
    }

    if (payload) {
        await notifyPayload(payload, snap);
    }
    return;
});
