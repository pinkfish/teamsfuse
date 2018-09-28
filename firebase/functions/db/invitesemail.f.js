'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const mailTransport = require('../util/mailgun')
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
            path: 'templates/invites/img/apple-store-badge.png',
            cid: 'apple-store',
         },
         {
            filename: 'google-store-badge.png',
            path: 'templates/invites/img/google-play-badge.png',
            cid: 'google-store',
        }
    ]

    var payloadTxt = handlebars.compile(fs.readFileSync('db/templates/invites/' + data.type + '.txt', 'utf8'))
    var payloadHtml = handlebars.compile(fs.readFileSync('db/templates/invites/' + data.type + '.html', 'utf8'))

    var mailOptions = {
        from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
        to: data.email
    };
    var context = {
        sendBy: sendByDoc.data(),
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
                    if (teamData.photoUrl === null) {
                        url = teamData.photoUrl;
                    } else {
                        url = 'templates/invites/img/defaultteam.jpg';
                    }

                    // Building Email message.
                    context.teamurl = url;
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
                            filename: 'team.png',
                            path: url,
                            cid: 'teamimg',
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

                    var mailOptions = {
                        from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                        to: data.email
                    };

                    var url;
                    if (playerData.photoUrl === null) {
                        url = playerData.photoUrl;
                    } else {
                        url = 'templates/invites/img/defaultplayer.jpg';
                    }

                     mailOptions.attachments.push(
                        {
                            filename: 'player.png',
                            path: url,
                            cid: 'playerimg',
                        }
                    );

                    context.player = playerData;
                    context.playerurl = url;

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
                var mailOptionsLeagueAdmin = {
                    from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                    to: data.email
                };

                var url;
                if (playerData.photoUrl === null) {
                    url = playerData.photoUrl;
                } else {
                    url = 'templates/invites/img/defaultleague.jpg';
                }

                 mailOptions.attachments.push(
                    {
                        filename: 'league.png',
                        path: url,
                        cid: 'leagueimg',
                    }
                );

                if (data.type === 'InviteType.LeagueAdmin') {
                    mailOptions.subject = "Invitation to join Leguae " + data.leagueName
                } else {
                    mailOptions.subject = "Invitation to join league team " + data.leagueName + ' ' + data.leagueTeamName
                }
                mailOptions.text = payloadTxt(context) + footerTxt(context);
                mailOptions.html = payloadHtml(context) + footerHtml(context);
                return mailTransport.sendMail(mailOptions);
            } else {
                return null;
            }
        });
    } else if (data.type === 'InviteType.Club') {
        return db.collection("Club")
                    .doc(data.clubUid)
                    .get().then(snapshot => {
            var mailOptionsClub = {
                from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                to: data.email
            };

            var url;
            if (playerData.photoUrl === null) {
                url = playerData.photoUrl;
            } else {
                url = 'templates/invites/img/defaultclub.jpg';
            }

             mailOptions.attachments.push(
                {
                    filename: 'cluv.png',
                    path: url,
                    cid: 'cluvimg',
                }
            );

            mailOptionsClub.subject = "Invitation to join club " + data.clubName
            mailOptions.text = payloadTxt(context) + footerTxt(context);
            mailOptions.html = payloadHtml(context) + footerHtml(context);

            return mailTransport.sendMail(mailOptionsClub);
        });
    }

    return data;
}
