'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const requestpromise = require('request-promise-native');
const mailTransport = require('../util/mailgun');
const handlebars = require('handlebars');
const fs = require('fs');

const db = admin.firestore();

// Sends an email confirmation when a user changes his mailing list subscription.
exports = module.exports = functions.firestore.document('/Invites/{id}').onWrite((inputData, context) => {
    const data = inputData.after.data();

    if (data === null) {
        // Delete...
        return null;
    }

    require('request').debug = true;

    // Already emailed about this invite.
    if (data.emailedInvite) {
        return null;
    }
    // lookup the person that sent the invite to get
    // their profile details.
    return db
        .collection('UserData')
        .doc(data.sentbyUid)
        .get()
        .then(sentByDoc => {
            return mailToSender(inputData.after, sentByDoc);
        })
        .then(stuff => {
            console.log('Sent email to ' + data.email);
            return db
                .collection('Invites')
                .doc(inputData.after.id)
                .update({ emailedInvite: true });
        })
        .catch(error => console.error('There was an error while sending the email:', error));
});

function mailToSender(inviteDoc, sentByDoc) {
    const data = inviteDoc.data();
    const footerTxt = handlebars.compile(fs.readFileSync('db/templates/invites/footer.txt', 'utf8'));
    const footerHtml = handlebars.compile(fs.readFileSync('db/templates/invites/footer.html', 'utf8'));
    const attachments = [
        {
            filename: 'apple-store-badge.png',
            path: 'db/templates/invites/img/apple-store-badge.png',
            cid: 'apple-store',
        },
        {
            filename: 'google-store-badge.png',
            path: 'db/templates/invites/img/google-play-badge.png',
            cid: 'google-store',
        },
    ];

    const payloadTxt = handlebars.compile(fs.readFileSync('db/templates/invites/' + data.type + '.txt', 'utf8'));
    const payloadHtml = handlebars.compile(fs.readFileSync('db/templates/invites/' + data.type + '.html', 'utf8'));

    const mailOptions = {
        from: '"' + sentByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
        to: data.email,
        attachments: attachments,
    };
    const context = {
        sentBy: sentByDoc.data(),
        invite: inviteDoc.data(),
    };

    if (data.type === 'InviteType.Team' || data.type === 'InviteType.Admin') {
        // Find the team details.
        return db
            .collection('Teams')
            .doc(data.teamUid)
            .get()
            .then(snapshot => {
                if (snapshot.exists) {
                    const teamData = snapshot.data();

                    let url;
                    if (teamData.photourl) {
                        url = teamData.photourl;
                    } else {
                        url = 'db/templates/invites/img/defaultteam.jpg';
                    }

                    // Building Email message.
                    context.teamimg = 'cid:teamurl';
                    context.team = teamData;
                    if (data.type === 'InviteType.Team') {
                        mailOptions.subject = 'Invitation to join ' + data.teamName;
                    } else {
                        mailOptions.subject = 'Invitation to be an admin for ' + teamData.name;
                    }
                    mailOptions.text = payloadTxt(context) + footerTxt(context);
                    mailOptions.html = payloadHtml(context) + footerHtml(context);

                    return Promise.all([mailOptions, getImageFromUrl(url)]);
                } else {
                    return null;
                }
            })
            .then(data => {
                if (data === null) {
                    return null;
                }
                const res = data[1];
                const mailOptions = data[0];

                mailOptions.attachments.push({
                    filename: 'team.jpg',
                    path: Buffer.from(res.body).toString('base64'),
                    cid: 'teamimg',
                    contentType: getContentType(res),
                    encoding: 'base64',
                });
                return mailTransport.sendMail(mailOptions);
            });
    } else if (data.type === 'InviteType.Player') {
        return db
            .collection('Players')
            .doc(data.playerUid)
            .get()
            .then(snapshot => {
                if (snapshot.exists) {
                    const playerData = snapshot.data();

                    let url;
                    if (playerData.photourl) {
                        url = playerData.photourl;
                    } else {
                        url = 'db/templates/invites/img/defaultplayer.jpg';
                    }

                    context.player = playerData;
                    context.playerimg = 'cid:playerimg';

                    mailOptions.subject = 'Invitation to join ' + playerData.name;
                    mailOptions.text = payloadTxt(context) + footerTxt(context);
                    mailOptions.html = payloadHtml(context) + footerHtml(context);

                    return Promise.all([mailOptions, getImageFromUrl(url)]);
                } else {
                    return null;
                }
            })
            .then(data => {
                if (data === null) {
                    return null;
                }
                const res = data[1];
                const mailOptions = data[0];

                mailOptions.attachments.push({
                    filename: 'player.jpg',
                    path: Buffer.from(res.body).toString('base64'),
                    cid: 'playerimg',
                    contentType: getContentType(res),
                    encoding: 'base64',
                });
                return mailTransport.sendMail(mailOptions);
            });
    } else if (data.type === 'InviteType.LeagueAdmin' || data.type === 'InviteType.LeagueTeam') {
        return db
            .collection('League')
            .doc(data.leagueUid)
            .get()
            .then(snapshot => {
                if (snapshot.exists) {
                    let url;
                    if (snapshot.data().photourl) {
                        url = snapshot.data().photourl;
                    } else {
                        url = 'db/templates/invites/img/defaultleague.jpg';
                    }

                    context.league = snapshot.data();
                    context.leagueimg = 'cid:leagueimg';
                    context.league.gender = context.league.gender.replace('Gender.', '').toLowerCase();
                    context.league.sport = context.league.sport.replace('Sport.', '').toLowerCase();

                    if (data.type === 'InviteType.LeagueAdmin') {
                        mailOptions.subject = 'Invitation to join Leguae ' + data.leagueName;
                    } else {
                        mailOptions.subject =
                            'Invitation to join league team ' + data.leagueName + ' ' + data.leagueTeamName;
                    }
                    mailOptions.text = payloadTxt(context) + footerTxt(context);
                    mailOptions.html = payloadHtml(context) + footerHtml(context);
                    return Promise.all([mailOptions, getImageFromUrl(url)]);
                } else {
                    return null;
                }
            })
            .then(data => {
                if (data === null) {
                    console.log('No league');
                    return null;
                }
                const mailOptions = data[0];
                const res = data[1];

                mailOptions.attachments.push({
                    filename: 'league.jpg',
                    content: Buffer.from(res.body).toString('base64'),
                    cid: 'leagueimg',
                    contentType: getContentType(res),
                    encoding: 'base64',
                });
                return mailTransport.sendMail(mailOptions);
            });
    } else if (data.type === 'InviteType.Club') {
        return db
            .collection('Club')
            .doc(data.clubUid)
            .get()
            .then(snapshot => {
                let url;
                if (snapshot.data().photourl) {
                    url = snapshot.data().photourl;
                } else {
                    url = 'db/templates/invites/img/defaultclub.jpg';
                }

                context.club = snapshot.data();
                context.clubimg = 'cid:clubimg';

                mailOptions.subject = 'Invitation to join club ' + data.clubName;
                mailOptions.text = payloadTxt(context) + footerTxt(context);
                mailOptions.html = payloadHtml(context) + footerHtml(context);

                return Promise.all([mailOptions, getImageFromUrl(url)]);
            })
            .then(data => {
                if (data === null) {
                    console.log('No league');
                    return null;
                }
                const mailOptions = data[0];
                const res = data[1];

                mailOptions.attachments.push({
                    filename: 'club.jpg',
                    content: Buffer.from(res.body).toString('base64'),
                    cid: 'clubimg',
                    contentType: getContentType(res),
                    encoding: 'base64',
                });
                return mailTransport.sendMail(mailOptions);
            });
    }

    return data;
}

function getImageFromUrl(url) {
    const getImageOptions = {
        url: url,
        encoding: null,
        resolveWithFullResponse: true,
    };
    return requestpromise(getImageOptions);
}

function getContentType(fullBody) {
    const contentType = res.headers['content-type'];
    if (contentType === 'application/octet-stream') {
        return 'image/jpeg';
    }
    return contentType;
}
