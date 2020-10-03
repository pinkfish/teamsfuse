import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onWrite = functions.firestore
    .document('/MessageRecipients/{messageid}')
    .onWrite(async (inputData, context) => {
        const data = inputData.after.data() ?? {};
        const previousData = inputData.before.data() ?? {};

        // See if the name is different.
        if (data.userId !== previousData.userId) {
            console.log('checking for duplicates ' + data.userId + ' ' + data.messageId);
            // Update everywhere.
            const snapshot = await db
                .collection('MessageRecipients')
                .where('userId', '==', data.userId)
                .where('messageId', '==', data.messageId)
                .get();

            console.log('checking for duplicates ' + snapshot.docs.length);

            if (snapshot.docs.length > 1) {
                // Set userid to 'ignore' and archived.
                await inputData.after.ref.update({
                    state: 'Archived',
                    userId: 'ignore',
                });
            }
        }

        return data;
    });
