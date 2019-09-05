'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const moment = require('moment-timezone');
const gamenotifypayload = require('./gamenotifypayload');

const db = admin.firestore();

exports = module.exports = functions.firestore.document('/Games/{gameid}').onUpdate((inputData, context) => {
    const data = inputData.after.data();
    const previousData = inputData.before.data();

    // Only notify if less then 7 days before the event.
    const arrivalTime = moment(data.arrivalTime);
    const nowTime = moment();
    const diff = arrivalTime.diff(nowTime, 'days');
    let payload = null;
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
            if (data.type === 'EventType.Practice') {
                payload = {
                    notification: {
                        title: 'Practice location {{team.name}}',
                        body: 'Arrive at {{arrivalTime}}',
                    },
                };
            } else if (data.type === 'EventType.Game') {
                payload = {
                    notification: {
                        title: 'Game Location vs {{opponent.name}}',
                        body: 'Arrive by {{arrivalTime}}',
                    },
                };
            } else if (data.type === 'EventType.Event') {
                payload = {
                    notification: {
                        title: 'Event location for {{team.name}}',
                        body: 'Arrive by {{arrivalTime}}',
                    },
                };
            }
        } else if (data.arrivalTime !== previousData.arrivalTime) {
            if (data.type === 'EventType.Practice') {
                payload = {
                    notification: {
                        title: 'Practice time {{team.name}}',
                        body: 'Arrive at {{arrivalTime}}',
                    },
                };
            } else if (data.type === 'EventType.Game') {
                payload = {
                    notification: {
                        title: 'Game time vs {{opponent.name}}',
                        body: 'Arrive by {{arrivalTime}}',
                    },
                };
            } else if (data.type === 'EventType.Event') {
                payload = {
                    notification: {
                        title: 'Event time for {{team.name}}',
                        body: 'Arrive by {{arrivalTime}}',
                    },
                };
            }
        }
    } else {
        console.log('Ignoring game out of range');
    }

    if (payload) {
        return gamenotifypayload.notifyPayload(payload, inputData.after);
    }

    return data;
});
