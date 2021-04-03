import * as functions from 'firebase-functions';
import { notifyPayload } from './gamenotifypayload';
import { PayloadData } from '../../util/notifyforgame';
import { DateTime, Duration } from 'luxon';

export const onGameDelete = functions.firestore.document('/Games/{gameid}').onDelete(async (snap, context) => {
    const data = snap.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = DateTime.fromMillis(data.arrivalTime).toUTC();
    const nowTime = DateTime.now().toUTC();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    if (diff.days <= 7 && nowTime.minus(Duration.fromObject({ minutes: 30 })).valueOf() < data.sharedData.time) {
        console.log('Changed in here');
        // Notify the user of the new event/training/game.
        if (data.sharedData.type === 'Practice') {
            payload = {
                title: 'CANCELLED practice for {{team.name}}',
                body: 'Cancelled practice at {[arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.sharedData.type === 'Game') {
            payload = {
                title: 'CANCELLED Game vs {{opponent.name}}',
                body: 'Cancelled game at {{arrivalTime}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.sharedData.type === 'EventType.Event') {
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

export default onGameDelete;
