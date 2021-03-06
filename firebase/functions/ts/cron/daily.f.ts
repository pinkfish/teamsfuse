import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as email from '../util/email';
import { v1 } from '@google-cloud/firestore';

import moment from 'moment-timezone';
import * as notifyforgame from '../util/notifyforgame';

const db = admin.firestore();
const client = new v1.FirestoreAdminClient();

// 4 days.
const CUT_OFF_DURATION = moment.duration({ days: 5 });
const LOOK_AHEAD_DURATION = moment.duration({ days: 1 });

export const onPublish = functions.pubsub.topic('daily-tick').onPublish(async (data, context) => {
    console.log('Doing the days work.');

    // Do something useful every day.
    try {
        console.log(process.env.FUNCTION_IDENTITY);
        for (const idx in admin.apps) {
            const app = admin.apps[idx];
            if (app === null || app === undefined) {
                console.log('Null app');
                continue;
            }
            console.log(app.name);
            console.log(app.options);
            console.log(app.options.serviceAccountId);
        }

        const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
        console.log(projectId);
        const databaseName = client.databasePath(projectId, '(default)');
        console.log(databaseName);
        const responses = await client.exportDocuments({
            name: databaseName,
            outputUriPrefix: 'gs://fusefirestorebucket/teamsfuse',
            // Backup the whole database.
            collectionIds: [],
        });
        const response = responses[0];
        console.log(`Operation Name: ${response['name']}`);
    } catch (err) {
        console.error(err);
    }
    console.log('Publishing...');

    const now = moment.utc().add(CUT_OFF_DURATION);
    const cutoff = moment.utc().subtract(LOOK_AHEAD_DURATION);
    const snapshot = await db
        .collection('Games')
        .where('arrivalTime', '>', cutoff.valueOf())
        .where('arrivalTime', '<', now.valueOf())
        .get();
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
                const payload: notifyforgame.PayloadData = {
                    from: 'noreply@email.teamsfuse.com',
                    title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                    text: email.TEXT_BODY,
                    body: email.HTML_BODY,
                    tag: 'email',
                    click_action: 'openGame',
                };
                await notifyforgame.emailForGame(doc, payload, '', 'emailUpcoming');
            }
        }
    }
    console.log('End publishing.');
    return;
});

export default onPublish;
