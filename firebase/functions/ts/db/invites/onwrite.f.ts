import * as functions from 'firebase-functions';
import * as handlebars from 'handlebars';
import * as fs from 'fs';
import * as admin from 'firebase-admin';
import axios, { AxiosRequestConfig, AxiosResponse } from 'axios';
import { sendMail } from '../../util/mailgun';
import { apiConfig } from '../../util/axios';

const db = admin.firestore();

const api = axios.create(apiConfig);

interface Attachment {
    filename: string;
    path?: string | undefined;
    cid: string;
    content?: string | undefined;
    contentType?: string | undefined;
    encoding?: string | undefined;
}

// Sends an email confirmation when a user changes his mailing list subscription.
export const onWrite = functions.firestore.document('/Invites/{id}').onWrite(async (inputData, context) => {
    if (inputData.after === null || inputData.after === undefined) {
        // Delete...
        console.log('Deleted');
        return null;
    }

    const data = inputData.after.data();

    if (data === null || data === undefined) {
        // Delete...
        console.log('empty data');
        return null;
    }

    // Already emailed about this invite.
    if (data.emailedInvite) {
        console.log('already emailed');
        return null;
    }

    // lookup the person that sent the invite to get
    // their profile details.
    const sentByDoc = await db.collection('UserData').doc(data.sentByUid).get();
    await mailToSender(inputData.after, sentByDoc);

    console.log('Sent email to ' + data.email);
    try {
        await db.collection('Invites').doc(inputData.after.id).update({ emailedInvite: true });
    } catch (error) {
        console.error('There was an error while sending the email:', error);
    }
    return;
});

async function mailToSender(
    inviteDoc: functions.firestore.DocumentSnapshot,
    sentByDoc: functions.firestore.DocumentSnapshot,
) {
    const data = inviteDoc.data();
    const footerTxt = handlebars.compile(fs.readFileSync('lib/ts/templates/invites/footer.txt', 'utf8'));
    const footerHtml = handlebars.compile(fs.readFileSync('lib/ts/templates/invites/footer.html', 'utf8'));
    const attachments: Attachment[] = [
        {
            filename: 'apple-store-badge.png',
            path: 'lib/ts/templates/invites/img/apple-store-badge.png',
            cid: 'apple-store',
        },
        {
            filename: 'google-store-badge.png',
            path: 'lib/ts/templates/invites/img/google-play-badge.png',
            cid: 'google-store',
        },
    ];

    if (data === null || data === undefined) {
        console.log('invalid data bits');
        return;
    }

    if (data.type === null || data.type === undefined) {
        console.log('Invalid invite type');
        return;
    }

    if (!fs.existsSync('lib/ts/templates/invites/InviteType.' + data.type + '.txt')) {
        console.log('File ' + 'lib/ts/templates/invites/InviteType.' + data.type + '.txt' + ' does not exist');
        return;
    }

    if (!fs.existsSync('lib/ts/templates/invites/InviteType.' + data.type + '.html')) {
        console.log('File ' + 'lib/ts/templates/invites/InviteType.' + data.type + '.html' + ' does not exist');
        return;
    }

    const payloadTxt = handlebars.compile(
        fs.readFileSync('lib/ts/templates/invites/InviteType.' + data.type + '.txt', 'utf8'),
    );
    const payloadHtml = handlebars.compile(
        fs.readFileSync('lib/ts/templates/invites/InviteType.' + data.type + '.html', 'utf8'),
    );

    const sentByData = sentByDoc.data() ?? {};

    const mailOptions = {
        from: '"' + sentByData.name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
        to: data.email,
        attachments: attachments,
        html: '',
        text: '',
        subject: '',
    };

    if (data.type === 'Team' || data.type === 'Admin') {
        // Find the team details.
        const snapshot = await db.collection('Teams').doc(data.teamUid).get();
        if (snapshot.exists) {
            const teamData = snapshot.data();
            if (teamData === null || teamData === undefined) {
                console.error('Snappy data is null');
                return;
            }

            let url;
            if (teamData.photourl) {
                url = teamData.photourl;
            } else {
                url = 'file:lib/ts/templates/invites/img/defaultteam.jpg';
            }

            // Building Email message.
            const context = {
                sentBy: sentByData,
                invite: data,
                teamimg: 'cid:teamimg',
                team: teamData,
            };
            if (data.type === 'Team') {
                mailOptions.subject = 'Invitation to join ' + data.teamName;
            } else {
                mailOptions.subject = 'Invitation to be an admin for ' + teamData.name;
            }
            mailOptions.text = payloadTxt(context) + footerTxt(context);
            mailOptions.html = payloadHtml(context) + footerHtml(context);

            const image = await getImageFromUrl(url);
            mailOptions.attachments.push({
                filename: 'team.jpg',
                content: Buffer.from(image.data).toString('base64'),
                cid: 'teamimg',
                contentType: getContentType(image),
                encoding: 'base64',
            });
            await sendMail(mailOptions);
        } else {
            return null;
        }
    } else if (data.type === 'Player') {
        const snapshot = await db.collection('Players').doc(data.playerUid).get();
        if (snapshot.exists) {
            const playerData = snapshot.data();
            if (playerData === null || playerData === undefined) {
                console.error('Snappy data is null');
                return;
            }

            let url;
            if (playerData.photourl) {
                url = playerData.photourl;
            } else {
                url = 'file:lib/ts/templates/invites/img/defaultplayer.jpg';
            }

            const context = {
                sentBy: sentByData,
                invite: data,

                player: playerData,
                playerimg: 'cid:playerimg',
            };

            mailOptions.subject = 'Invitation to join ' + playerData.name;
            mailOptions.text = payloadTxt(context) + footerTxt(context);
            mailOptions.html = payloadHtml(context) + footerHtml(context);

            const imageUrl = await getImageFromUrl(url);
            mailOptions.attachments.push({
                filename: 'player.jpg',
                content: Buffer.from(imageUrl.data).toString('base64'),
                cid: 'playerimg',
                contentType: getContentType(imageUrl),
                encoding: 'base64',
            });
            await sendMail(mailOptions);
        } else {
            return null;
        }
    } else if (data.type === 'LeagueAdmin' || data.type === 'LeagueTeam') {
        const snapshot = await db.collection('League').doc(data.leagueUid).get();
        if (snapshot.exists) {
            let url;
            const snapData = snapshot.data() ?? {};
            if (snapData.photourl) {
                url = snapData.photourl;
            } else {
                url = 'file:lib/ts/templates/invites/img/defaultleague.jpg';
            }

            const context = {
                sentBy: sentByData,
                invite: data,

                league: snapshot.data(),
                leagueimg: 'cid:leagueimg',
                'league.gender': snapData.gender.replace('Gender.', '').toLowerCase(),
                'league.sport': snapData.sport.replace('Sport.', '').toLowerCase(),
            };

            if (data.type === 'LeagueAdmin') {
                mailOptions.subject = 'Invitation to join Leguae ' + data.leagueName;
            } else {
                mailOptions.subject = 'Invitation to join league team ' + data.leagueName + ' ' + data.leagueTeamName;
            }
            mailOptions.text = payloadTxt(context) + footerTxt(context);
            mailOptions.html = payloadHtml(context) + footerHtml(context);
            const image = await getImageFromUrl(url);
            mailOptions.attachments.push({
                filename: 'league.jpg',
                content: Buffer.from(image.data).toString('base64'),
                cid: 'leagueimg',
                contentType: getContentType(image),
                encoding: 'base64',
            });
            await sendMail(mailOptions);
        } else {
            return null;
        }
    } else if (data.type === 'Club') {
        const snapshot = await db.collection('Clubs').doc(data.clubUid).get();
        const snappyData = snapshot.data();
        if (snappyData === null || snappyData === undefined) {
            console.error('Snappy data is null');
            return;
        }
        let url;
        if (snappyData.photourl) {
            url = snappyData.photourl;
        } else {
            url = 'file:lib/ts/templates/invites/img/defaultclub.jpg';
        }

        const context = {
            sentBy: sentByData,
            invite: data,
            club: snapshot.data(),
            clubimg: 'cid:clubimg',
        };

        mailOptions.subject = 'Invitation to join club ' + data.clubName;
        mailOptions.text = payloadTxt(context) + footerTxt(context);
        mailOptions.html = payloadHtml(context) + footerHtml(context);

        const image = await getImageFromUrl(url);

        mailOptions.attachments.push({
            filename: 'club.jpg',
            content: Buffer.from(image.data).toString('base64'),
            cid: 'clubimg',
            contentType: getContentType(image),
            encoding: 'base64',
        });
        await sendMail(mailOptions);
    }

    return data;
}

function getImageFromUrl(url: string): Promise<AxiosResponse> {
    if (url.startsWith('file:')) {
        return new Promise(function (resolve, reject) {
            fs.readFile(url.substring(5), (err, data) => {
                if (err !== null && err !== undefined) {
                    reject(err);
                } else {
                    // Only need the data since the headers not being there will default
                    // to jpg.
                    const response: AxiosResponse = {
                        data: data,
                        status: 200,
                        statusText: 'OK',
                        headers: { 'content-type': url.endsWith('.png') ? 'image/png' : 'image/jpeg' },
                        config: {},
                    };
                    resolve(response);
                }
            });
        });
    }
    const getImageOptions: AxiosRequestConfig = {
        responseType: 'arraybuffer',
    };
    return api.get(url, getImageOptions);
}

function getContentType(fullBody: AxiosResponse) {
    const contentType = fullBody.headers['content-type'];
    if (contentType === 'application/octet-stream') {
        return 'image/jpeg';
    }
    return contentType;
}

export default onWrite;
