import * as functions from 'firebase-functions';
import { notifyPayload, notifyOfResults } from './gamenotifypayload';
import { PayloadData } from '../../util/notifyforgame';
import { DateTime, Duration } from 'luxon';
import { DataNodeCache } from '../../util/datacache';

export const onGameUpdate = functions.firestore.document('/Games/{gameid}').onUpdate(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = DateTime.fromMillis(data.arrivalTime);
    const nowTime = DateTime.now().toUTC();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    console.log('on change ' + inputData.after.id + ' diff ' + diff);
    if (diff.days <= 7 && nowTime.minus(Duration.fromObject({ minutes: 30 })).valueOf() < data.arrivalTime) {
        console.log('Changed in here');
        // Notify the user of the new event/training/game.
        // Only mention big changes, address change, time change.
        if (previousData.sharedData.place === null) {
            previousData.sharedData.place = {};
        }
        const bing =
            data.sharedData.place.address !== previousData.sharedData.place.address ||
            data.opponentUid !== previousData.opponentUid ||
            data.arrivalTime !== previousData.arrivalTime;
        if (bing) {
            if (data.sharedData.type === 'Practice') {
                payload = {
                    title: 'Practice change for {{team.name}}',
                    body: 'Arrive by {{arrivalTime}} at {{placeName}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            } else if (data.sharedData.type === 'Game') {
                payload = {
                    title: 'Game change vs {{opponent.name}}',
                    body: 'Arrive by {{arrivalTime}} at {{placeName}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            } else if (data.sharedData.type === 'Event') {
                payload = {
                    title: 'Event change for {{team.name}}',
                    body: '{{game.name}} arrive by {{arrivalTime}} at {{placeName}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            }
        }
    } else {
        console.log('Ignoring game out of range');
    }

    const cache = new DataNodeCache();

    if (payload) {
        await notifyPayload(payload, inputData.after, cache);
    }

    await notifyOfResults(inputData.after, previousData, cache, context.auth?.uid ?? '');

    return;
});

export default onGameUpdate;
