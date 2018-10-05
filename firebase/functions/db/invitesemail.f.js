'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const requestpromise = require('request-promise-native');
const mailTransport = require('../util/mailgun');
/*
const mailTransport = nodemailer.createTransport({
    host: 'smtp.ethereal.email',
        port: 587,
        auth: {
            user: 'sajca5nyi7mtjhr5@ethereal.email',
            pass: 'uqNgHtqJDyqtnbpSY3'
        }
});
*/
const handlebars = require('handlebars');
var fs = require('fs');

var db = admin.firestore();

const teamsFuseFooterHtml = "<p><i><a href='http://www.teamsfuse.com'>TeamsFuse</a></i> is an app to " +
    "help organize your sports teams.<p>";
const teamsFuseFooterPlain = "\n\nTeamsFuse is an app to " +
    "help organize your sports teams.\nhttp://www.teamsfuse.com";

// Sends an email confirmation when a user changes his mailing list subscription.
exports = module.exports = functions.firestore.document('/Invites/{id}').onWrite((inputData, context) => {
    const data = inputData.after.data();

    require('request').debug = true;

    // Already emailed about this invite.
    if (data.emailedInvite) {
        return null;
    }
    // lookup the person that sent the invite to get
    // their profile details.
    return db.collection('UserData').doc(data.sentbyUid).get()
        .then(sentByDoc => {
            return mailToSender(inputData.after, sentByDoc);
        }).then((stuff) => {
            console.log("Sent email to " + data.email);
            return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
        })
        .catch((error) => console.error("There was an error while sending the email:", error));

});


function mailToSender(inviteDoc, sentByDoc) {
    var data = inviteDoc.data()
    var footerTxt = handlebars.compile(fs.readFileSync('db/templates/invites/footer.txt', 'utf8'))
    var footerHtml = handlebars.compile(fs.readFileSync('db/templates/invites/footer.html', 'utf8'))
    var attachments = [
        {
            filename: 'apple-store-badge.png',
            path: 'db/templates/invites/img/apple-store-badge.png',
            cid: 'apple-store',
         },
         {
            filename: 'google-store-badge.png',
            path: 'db/templates/invites/img/google-play-badge.png',
            cid: 'google-store',
        }
    ]

    var payloadTxt = handlebars.compile(fs.readFileSync('db/templates/invites/' + data.type + '.txt', 'utf8'))
    var payloadHtml = handlebars.compile(fs.readFileSync('db/templates/invites/' + data.type + '.html', 'utf8'))

    var mailOptions = {
        from: '"' + sentByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
        to: data.email,
        attachments: attachments
    };
    var context = {
        sentBy: sentByDoc.data(),
        invite: inviteDoc.data(),
    }

    if (data.type === 'InviteType.Team'||
        data.type === 'InviteType.Admin') {
       // Find the team details.
        return db.collection("Teams")
            .doc(data.teamUid)
            .get().then(snapshot => {
                if (snapshot.exists) {
                    const teamData = snapshot.data();

                    var url;
                    if (teamData.photourl) {
                        url = teamData.photourl;
                    } else {
                        url = 'db/templates/invites/img/defaultteam.jpg';
                    }

                    // Building Email message.
                    context.teamimg = 'cid:teamurl';
                    context.team = teamData;
                    if (data.type === 'InviteType.Team') {
                        mailOptions.subject = "Invitation to join " + data.teamName;
                    } else {
                        mailOptions.subject = "Invitation to be an admin for " + teamData.name
                    }
                    mailOptions.text = payloadTxt(context) + footerTxt(context);
                    mailOptions.html = payloadHtml(context) + footerHtml(context);
                    mailOptions.attachments.push(
                        {
                            filename: 'team.jpg',
                            path: url,
                            cid: 'teamimg',
                            image: 'image/jpg',
                        }
                    );

                    return mailTransport.sendMail(mailOptions);
                } else {
                    return null;
                }
            });
    } else if (data.type === 'InviteType.Player') {
        return db.collection("Players").doc(data.playerUid).get()
            .then(snapshot => {
                 if (snapshot.exists) {
                    const playerData = snapshot.data();

                    var url;
                    if (playerData.photourl) {
                        url = playerData.photourl;
                    } else {
                        url = 'db/templates/invites/img/defaultplayer.jpg';
                    }

                    mailOptions.attachments.push(
                        {
                            filename: 'player.jpg',
                            path: url,
                            cid: 'playerimg',
                            contentType: 'image/jpg',
                        }
                    );

                    context.player = playerData;
                    context.playerimg = 'cid:playerimg';

                    mailOptions.subject = "Invitation to join " + playerData.name
                    mailOptions.text = payloadTxt(context) + footerTxt(context);
                    mailOptions.html = payloadHtml(context) + footerHtml(context);

                    return mailTransport.sendMail(mailOptions);
                } else {
                    return null;
                }
            })
    } else if (data.type === 'InviteType.LeagueAdmin' ||
               data.type === 'InviteType.LeagueTeam') {
        return db.collection("League")
            .doc(data.leagueUid)
            .get().then(snapshot => {
            if (snapshot.exists) {
                var url;
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
                    mailOptions.subject = "Invitation to join Leguae " + data.leagueName
                } else {
                    mailOptions.subject = "Invitation to join league team " + data.leagueName + ' ' + data.leagueTeamName
                }
                mailOptions.text = payloadTxt(context) + footerTxt(context);
                mailOptions.html = payloadHtml(context) + footerHtml(context);
                const getImageOptions = {
                  url: url,
                  encoding: null,
                  resolveWithFullResponse: true
                };
                return requestpromise(getImageOptions).then(res => {
                    mailOptions.attachments.push(
                                    {
                                        filename: 'league.jpg',
                                        content: Buffer.from(res.body).toString('base64'),
                                        cid: 'leagueimg',
                                        contentType: res.headers['content-type'],
                                        encoding: 'base64',
                                    }
                                );
                    return mailTransport.sendMail(mailOptions);
                });
            } else {
                return null;
            }
        });
    } else if (data.type === 'InviteType.Club') {
        return db.collection("Club")
                    .doc(data.clubUid)
                    .get().then(snapshot => {

            var url;
            if (snapshot.data().photourl) {
                url = snapshot.data().photourl;
            } else {
                url = 'db/templates/invites/img/defaultclub.jpg';
            }

             mailOptions.attachments.push(
                {
                    filename: 'club.jpg',
                    path: url,
                    cid: 'clubimg',
                    image: 'image/jpg'
                }
            );

            context.club = snapshot.data();
            context.clubimg = 'cid:clubimg';

            mailOptions.subject = "Invitation to join club " + data.clubName
            mailOptions.text = payloadTxt(context) + footerTxt(context);
            mailOptions.html = payloadHtml(context) + footerHtml(context);

            return mailTransport.sendMail(mailOptions);
        });
    }

    return data;
}
