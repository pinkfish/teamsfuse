import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as email from '../util/email';
import { v1 } from '@google-cloud/firestore';

import { DateTime, Duration } from 'luxon';
import * as notifyforgame from '../util/notifyforgame';
import { DataNodeCache } from '../util/datacache';

const db = admin.firestore();
// Exported for testing.
const client = new v1.FirestoreAdminClient();

export const testExport = {
    doExport: async (databaseName: string): Promise<void> => {
        client
            .exportDocuments({
                name: databaseName,
                outputUriPrefix: 'gs://fusefirestorebucket/teamsfusebackup',
                // Backup the whole database.
                collectionIds: [],
            })
            .then((responses) => {
                const response = responses[0];
                console.log(`Operation Name: ${response['name']}`);

                return;
            })
            .catch((err) => {
                console.error(err);
            });
    },
};

// 4 days.
const CUT_OFF_DURATION = Duration.fromObject({ days: 1 });
const LOOK_AHEAD_DURATION = Duration.fromObject({ days: 5 });

export const onDailyPublish = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    // Do something useful every day.
    try {
        for (const idx in admin.apps) {
            const app = admin.apps[idx];
            if (app === null || app === undefined) {
                console.error('Null app');
                continue;
            }
        }

        const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
        if (projectId !== undefined) {
            const databaseName = client.databasePath(projectId, '(default)');
            await testExport.doExport(databaseName);
        }
    } catch (err) {
        console.error(err);
    }

    const now = DateTime.now().toUTC().plus(LOOK_AHEAD_DURATION);
    const cutoff = DateTime.now().toUTC().minus(CUT_OFF_DURATION);
    const snapshot = await db
        .collection('Games')
        .where('arrivalTime', '>', cutoff.valueOf())
        .where('arrivalTime', '<', now.valueOf())
        .where('sharedData.type', '==', 'Game')
        .get();
    const cache = new DataNodeCache();
    try {
        for (const index in snapshot.docs) {
            if (Object.prototype.hasOwnProperty.call(snapshot.docs, index)) {
                const doc = snapshot.docs[index];
                const docData = doc.data();
                if (docData.notifiedEmail) {
                    continue;
                }
                // Only email about games.
                const sharedGameData = docData.sharedData;
                if (sharedGameData === null || sharedGameData === undefined) {
                    console.error('Cannot find shared data ' + doc.id);
                    continue;
                }

                if (sharedGameData.type === 'Game') {
                    const payload: notifyforgame.PayloadData = {
                        from: 'noreply@email.teamsfuse.com',
                        title: '[{{team.name}}] Game at {{startTime}} vs {{opponent.name}}',
                        text: email.TEXT_BODY,
                        body: email.HTML_BODY,
                        tag: 'email',
                        click_action: 'openGame',
                    };
                    try {
                        await notifyforgame.emailForGame(
                            doc,
                            payload,
                            '',
                            'emailUpcoming',
                            cache,
                            new notifyforgame.ChangedData(),
                        );
                        // Write out that we notified for this games.ChangedData
                        await db.collection('Games').doc(doc.id).update({
                            notifiedEmail: true,
                        });
                    } catch (e) {
                        console.error('Error sending mail for ' + doc.id);
                        console.error(e);
                    }
                }
            }
        }
    } finally {
        cache.close();
    }
    return;
});

export default onDailyPublish;
