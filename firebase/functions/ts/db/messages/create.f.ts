import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as handlebars from 'handlebars';
import * as fs from 'fs';
import { getContentType, getImageFromUrl, Attachment } from '../../util/sendemail';
import { sendMail } from '../../util/mailgun';
import { DateTime } from 'luxon';
import { getShortLink } from '../../util/dynamiclinks';

const db = admin.firestore();

const messageTxt = handlebars.compile(fs.readFileSync('lib/ts/templates/message/message.txt', 'utf8'));
const messageHtml = handlebars.compile(fs.readFileSync('lib/ts/templates/message/message.html', 'utf8'));

export const onMessageCreate = functions.firestore
    .document('/MessageRecipients/{messageid}')
    .onCreate(async (doc, context) => {
        const data = doc.data() ?? {};

        // If it exists afterwards, copy it to the message.
        const idx = `recipients.${data.userId}`;
        await db
            .collection('Messages')
            .doc(data.messageId)
            .update({
                [idx]: data,
            });

        // Update everywhere.
        const snapshot = await db
            .collection('MessageRecipients')
            .where('userId', '==', data.userId)
            .where('messageId', '==', data.messageId)
            .get();

        if (snapshot.docs.length > 1) {
            // Set userid to 'ignore' and archived.
            await doc.ref.update({
                state: 'Archived',
                userId: 'ignore',
            });
        }

        // Update everywhere.
        const playerDoc = await db.collection('Players').doc(data.playerId).get();
        if (playerDoc.exists) {
            const playerData = playerDoc.data();
            if (playerData === null || playerData === undefined) {
                console.error('Error in the snappy data');
                return;
            }

            const users = playerData.users;
            let setupFirst = false;
            for (const userId in users) {
                if (users.hasOwnProperty(userId)) {
                    if (!setupFirst) {
                        setupFirst = true;
                        data.userId = userId;
                        await doc.ref.update({
                            userId: userId,
                        });

                        // Send email.
                        await sendTheEmail(doc, userId, playerDoc);
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
                            const newDoc = await db.collection('MessageRecipients').doc().get();
                            data.userId = userId;
                            data.uid = newDoc.id;

                            console.log('Making a copy ' + userId + ' ' + recipients.docs.length);

                            await newDoc.ref.set(data);

                            await sendTheEmail(doc, userId, playerDoc);
                        }
                    }
                }
            }
        }

        return data;
    });

async function sendTheEmail(
    recipient: functions.firestore.DocumentSnapshot,
    userId: string,
    toPlayer: functions.firestore.DocumentSnapshot,
) {
    const data = recipient.data();
    if (data === undefined || data === null) {
        console.error('Invalid message recipient');
        return;
    }
    const toPlayerData = toPlayer.data();
    if (toPlayerData === undefined || toPlayerData === null) {
        console.error('Invalid to player ' + toPlayer.id);
        return;
    }

    const fromPlayer = await db.collection('Players').doc(data.fromUid).get();
    const fromPlayerData = fromPlayer.data();
    if (fromPlayerData === null || fromPlayerData === undefined) {
        console.error('Invalid user from data ' + data.fromUid);
        return;
    }

    const message = await db.collection('Messages').doc(data.messageId).get();
    const messageData = message.data();
    if (messageData === null || messageData === undefined) {
        console.error('Invalid message data ' + data.messageId);
        return;
    }

    const team = await db.collection('Teams').doc(messageData.teamUid).get();
    const teamData = team.data();
    if (teamData === null || teamData === undefined) {
        console.error('Invalid team data ' + messageData.teamUid);
        return;
    }

    const user = await db.collection('UserData').doc(userId).get();
    const userData = user.data();
    if (userData === null || userData === undefined) {
        console.error('Invalid user to data ' + userId);
        return;
    }

    const messageBody = await db
        .collection('Messages')
        .doc(data.messageId)
        .collection('Messages')
        .doc(data.messageId)
        .get();
    const messageBodyData = messageBody.data();

    if (messageBodyData === null || messageBodyData === undefined) {
        console.error('Invalid message body data');
        return;
    }

    if (teamData && messageData && messageBodyData && userData && fromPlayerData) {
        // Send email.
        const sentTime = DateTime.fromMillis(messageData.timeSent)
            .setZone(toPlayerData.timezone ?? 'America/Los_Angeles')
            .toFormat('ffff');

        const messageLink = await getShortLink(messageData.subject, '/Message/View/' + data.uid);
        const mailContext = {
            team: teamData,
            playerPhotoUrl: 'cid:playerimg',
            player: toPlayerData,
            message: messageData,
            recipient: data,
            fromPlayer: fromPlayerData,
            messageBody: messageBodyData.body,
            user: userData,
            sentTime: sentTime,
            messageLink: messageLink,
        };

        const footerTxt = handlebars.compile(fs.readFileSync('lib/ts/templates/footer.txt', 'utf8'));
        const footerHtml = handlebars.compile(fs.readFileSync('lib/ts/templates/footer.html', 'utf8'));
        let attachments: Attachment[];
        try {
            const image = await getImageFromUrl(data.photoUrl, 'lib/ts/templates/img/defaultplayer.jpg');

            attachments = [
                {
                    filename: 'apple-store-badge.png',
                    path: 'lib/ts/templates/img/apple-store-badge.png',
                    cid: 'apple-store',
                },
                {
                    filename: 'google-store-badge.png',
                    path: 'lib/ts/templates/img/google-play-badge.png',
                    cid: 'google-store',
                },
                {
                    filename: 'player.jpg',
                    content: Buffer.from(image.data).toString('base64'),
                    cid: 'playerimg',
                    contentType: getContentType(image),
                    encoding: 'base64',
                },
            ];
        } catch (e) {
            // No team image...
            attachments = [
                {
                    filename: 'apple-store-badge.png',
                    path: 'lib/ts/templates/img/apple-store-badge.png',
                    cid: 'apple-store',
                },
                {
                    filename: 'google-store-badge.png',
                    path: 'lib/ts/templates/img/google-play-badge.png',
                    cid: 'google-store',
                },
            ];
        }

        const sendPayload = {
            subject: '[' + teamData.name + '] ' + messageData.subject,
            text: messageTxt(mailContext) + footerTxt(mailContext),
            html: messageHtml(mailContext) + footerHtml(mailContext),
            from: `"${fromPlayerData.name} <${data.uid}@email.teamsfuse.com>`,
            to: userData.email,
            attachments: attachments,
        };
        try {
            console.log(sendPayload);
            await sendMail(sendPayload);
        } catch (error) {
            console.error('Error mailing ' + error);
        }
    } else {
        console.error('Invalid input data');
    }
}

export default onMessageCreate;
