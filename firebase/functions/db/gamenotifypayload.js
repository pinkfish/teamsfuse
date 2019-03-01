'use strict';

const moment = require('moment-timezone');
const notifyforgame = require('../util/notifyforgame');
const functions = require('firebase-functions');

exports.notifyPayload = (payload, snap) => {
    if (payload) {
        var data = snap.data();
        var nowTime = moment();

        payload.notification.body += ' for {{team.name}}';
        payload.notification.body += ' located {{game.place.address}}'
        if (data.uniform !== '') {
            payload.notification.body += ' wear {{game.uniform}}';
        }

        var gameTime = moment(data.time).add(moment.duration({hours:3}));
        var diffGameTime = gameTime.diff(nowTime, 'seconds');

        payload['android'] = {
            ttl: diffGameTime * 1000,
            collapse_key: snap.id + 'change',
            notification: {
                tag: snap.id + 'change',
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
            }
        }
        payload['apns'] = {
            headers: {
                'apns-expiration': String(Math.floor(gameTime.valueOf() / 1000)),
                'apns-collapse-id': snap.id + 'change'
            },
            payload: {
                aps: {
                    'category': 'GAME',
                    alert: {
                        'thread-id': snap.id
                    }
                }
            }
        }
        return Promise.all([
            notifyforgame.notifyForGame(snap, payload, null),
            //notifyforgame.emailForGame(inputData.after, payload, '', 'emailOnUpdates')
        ]);
    }
    return data;
}
