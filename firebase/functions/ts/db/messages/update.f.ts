import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onMessageWrite = functions.firestore
    .document('/MessageRecipients/{messageid}')
    .onWrite(async (inputData, context) => {
        const data = inputData.after.data() ?? {};
        const previousData = inputData.before.data() ?? {};

        // If it exists afterwards, copy it to the message.
        if (inputData.after.exists) {
            const idx = `recipients.${data.userId}`;
            await db
                .collection('Messages')
                .doc(data.messageId)
                .update({
                    [idx]: data,
                });
        }

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

        // See if the name is different.
        if (data.userId === null) {
            console.log('new message!', data.after.id);
            // Update everywhere.
            const snapshot = await db.collection('Players').doc(data.playerId).get();
            if (snapshot.exists) {
                const snappyData = snapshot.data();
                if (snappyData === null || snappyData === undefined) {
                    console.log('Error in the snappy data');
                    return;
                }

                const users = snappyData.user;
                let setupFirst = false;
                console.log(snappyData);
                console.log(users);
                for (const userId in users) {
                    console.log('Checking ' + userId);
                    if (Object.prototype.hasOwnProperty.call(users, userId)) {
                        if (!setupFirst) {
                            console.log('Updating first ' + userId);
                            setupFirst = true;
                            data.userId = userId;
                            await inputData.after.ref.set(
                                {
                                    userId: userId,
                                },
                                {
                                    merge: true,
                                },
                            );

                            // Send email.
                        } else {
                            // Make a copy and fill in the details with the new user.
                            // Only do this if there is not already a messageid tracked for
                            // this user.
                            const recipients = await db
                                .collection('MessageRecipients')
                                .where('userId', '==', userId)
                                .where('messageId', '==', data.messageId)
                                .get();
                            if (recipients.docs.length === 0) {
                                console.log('zero count');
                                data.userId = userId;
                                console.log('Making a copy ' + userId + ' ' + recipients.docs.length);

                                await db.collection('MessageRecipients').add(data);
                                // Send email.
                            }
                        }
                    }
                }
            }
        }

        return data;
    });

export default onMessageWrite;
