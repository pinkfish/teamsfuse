import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onMessageUpdate = functions.firestore
    .document('/MessageRecipients/{messageid}')
    .onUpdate(async (inputData, context) => {
        const data = inputData.after.data() ?? {};

        // If it exists afterwards, copy it to the message.
        const idx = `recipients.${data.userId}`;
        await db
            .collection('Messages')
            .doc(data.messageId)
            .update({
                [idx]: data,
            });

        return data;
    });

export default onMessageUpdate;
