'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const email = require('../util/email');
const moment = require('moment-timezone');
const notifyforgame = require('../util/notifyforgame');

const db = admin.firestore();

// 4 days.
const CUT_OFF_DURATION = moment.duration({ days: 5 });
const LOOK_AHEAD_DURATION = moment.duration({ days: 1 });

exports = module.exports = functions.pubsub.topic('daily-tick').onPublish((data, context) => {
    // Do something useful every day.

    const now = moment().add(CUT_OFF_DURATION);
    const cutoff = moment().subtract(LOOK_AHEAD_DURATION);
    return db
        .collection('Games')
        .where('arrivalTime', '>', cutoff.valueOf())
        .where('arrivalTime', '<', now.valueOf())
        .get()
        .then(snapshot => {
            const promiseEmail = [snapshot.docs];
            for (const index in snapshot.docs) {
                if (Object.prototype.hasOwnProperty.call(snapshot.docs, index)) {
                    const doc = snapshot.docs[index];
                    console.log('Checking game ' + doc.id);
                    if (doc.data().notifiedEmail) {
                        console.log('Already notified about ' + doc.id);
                        continue;
                    }
                    // Only email about games.
                    console.log(doc.data().type);
                    if (doc.data().type === 'EventType.Game') {
                        const payload = {
                            from: 'noreply@email.teamsfuse.com',
                            subject: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                            text: email.TEXT_BODY,
                            html: email.HTML_BODY,
                        };
                        promiseEmail.push(notifyforgame.emailForGame(doc, payload, '', 'emailUpcoming'));
                    }
                }
            }
            return Promise.all(promiseEmail);
        });
});
