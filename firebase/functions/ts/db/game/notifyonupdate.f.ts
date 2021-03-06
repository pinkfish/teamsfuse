import * as functions from 'firebase-functions';
import { notifyPayload } from './gamenotifypayload';
import * as moment from 'moment-timezone';
import { PayloadData } from '../../util/notifyforgame';

export const onUpdate = functions.firestore.document('/Games/{gameid}').onUpdate(async (inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = moment.utc(data.arrivalTime);
    const nowTime = moment.utc();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload: PayloadData | null = null;
    console.log('on change ' + inputData.after.id + ' diff ' + diff);
    if (diff <= 7 && nowTime.valueOf() < data.arrivalTime.valueOf() - 1000 * 60 * 60) {
        console.log('Changed in here');
        // Notify the user of the new event/training/game.
        // Only mention big changes, address change, time change.
        if (previousData.place === null) {
            previousData.place = {};
        }
        const bing = true;
        if (data.uniform !== previousData.uniform || data.opponentUid !== previousData.opponentUid || bing) {
            if (data.type === 'Practice') {
                payload = {
                    title: 'Practice location {{team.name}}',
                    body: 'Arrive at {{arrivalTime}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            } else if (data.type === 'Game') {
                payload = {
                    title: 'Game Location vs {{opponent.name}}',
                    body: 'Arrive by {{arrivalTime}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            } else if (data.type === 'Event') {
                payload = {
                    title: 'Event location for {{team.name}}',
                    body: 'Arrive by {{arrivalTime}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            }
        } else if (data.arrivalTime !== previousData.arrivalTime) {
            if (data.type === 'Practice') {
                payload = {
                    title: 'Practice time {{team.name}}',
                    body: 'Arrive at {{arrivalTime}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            } else if (data.type === 'Game') {
                payload = {
                    title: 'Game time vs {{opponent.name}}',
                    body: 'Arrive by {{arrivalTime}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            } else if (data.type === 'Event') {
                payload = {
                    title: 'Event time for {{team.name}}',
                    body: 'Arrive by {{arrivalTime}}',
                    tag: inputData.after.id + 'change',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                };
            }
        }
    } else {
        console.log('Ignoring game out of range');
    }

    if (payload) {
        await notifyPayload(payload, inputData.after);
    }

    return;
});

export default onUpdate;
