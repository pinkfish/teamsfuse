import * as functions from 'firebase-functions';
import { notifyPayload } from './gamenotifypayload';
import { PayloadData } from '../../util/notifyforgame';
import { DateTime, Duration } from 'luxon';
import { DataNodeCache } from '../../util/datacache';

export const onGameDelete = functions.firestore.document('/Games/{gameid}').onDelete(async (snap, context) => {
    const data = snap.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = DateTime.fromMillis(data.arrivalTime).toUTC();
    const nowTime = DateTime.now().toUTC();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    if (diff.days <= 7 && nowTime.minus(Duration.fromObject({ minutes: 30 })).valueOf() < data.sharedData.time) {
        // Notify the user of the new event/training/game.
        if (data.sharedData.type === 'Practice') {
            payload = {
                title: 'CANCELLED Practice for {{team.name}}',
                body: 'Cancelled practice at {{arrivalTime}} located {{placeName}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.sharedData.type === 'Game') {
            payload = {
                title: 'CANCELLED Game vs {{opponent.name}}',
                body: 'Cancelled game at {{arrivalTime}} ' + 'for {{team.name}} ' + 'located {{placeName}}',

                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.sharedData.type === 'Event') {
            payload = {
                title: 'CANCELLED Event for {{team.name}}',
                body: 'Cancelled event at {{arrivalTime}} located {{placeName}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        }
    }

    if (payload) {
        const cache = new DataNodeCache();

        await notifyPayload(payload, snap, cache);
    }
    return;
});

export default onGameDelete;
