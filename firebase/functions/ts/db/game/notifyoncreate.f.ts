import * as functions from 'firebase-functions';
import { notifyPayload } from './gamenotifypayload';
import { PayloadData } from '../../util/notifyforgame';
import { DateTime, Duration } from 'luxon';
import { DataNodeCache } from '../../util/datacache';

export const onGameCreate = functions.firestore.document('/Games/{gameid}').onCreate((snap, context) => {
    const data = snap.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = DateTime.fromMillis(data.arrivalTime);
    const nowTime = DateTime.now().toUTC();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    if (diff.days <= 7 && nowTime.minus(Duration.fromObject({ minutes: 30 })).valueOf() < data.sharedData.time) {
        // Notify the user of the new event/training/game.
        if (data.sharedData.type === 'Practice') {
            payload = {
                title: 'New Practice for {{team.name}}',
                body: 'New practice arrive by {{arrivalTime}} at {{placeName}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.sharedData.type === 'Game') {
            payload = {
                title: 'New Game vs {{opponent.name}}',
                body: 'New game arrive by {{arrivalTime}} ' + 'for {{team.name}} ' + 'at {{placeName}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        } else if (data.sharedData.type === 'Event') {
            payload = {
                title: 'New Event for {{team.name}}',
                body: 'New event {{game.name}} arrive by {{arrivalTime}} at {{placeName}}',
                tag: snap.id + 'change',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };
        }
    }

    if (payload) {
        const cache = new DataNodeCache();

        return notifyPayload(payload, snap, cache);
    }
    return data;
});

export default onGameCreate;
