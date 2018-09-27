'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const mailTransport = require('../util/mailgun')
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
    var userSentPromise =  db.collection('UserData').doc(data.sentbyUid).get();

        if (data.type === 'InviteType.Team') {
            // Find the team details.
            return Promises.all([db.collection("Teams")
                .doc(data.teamUid)
                .get(),
                userSentPromise
                ]).then(stuff => {
                    var snapshot = stuff[0];
                    var sendByDoc = stuff[1];
                    if (snapshot.exists) {
                        const teamData = snapshot.data();
                        var mailOptions = {
                            from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                            to: data.email
                        };

                        var url;
                        if (teamData.photoUrl === null) {
                            url = teamData.photoUrl;
                        } else {
                            url = 'http://www.teamsfuse.com/photos/abstractphotos.jpg';
                        }

                        // Building Email message.
                        mailOptions.subject = "Invitation to join " + data.teamName
                        mailOptions.text = "You are invited to join " + data.teamName +
                            " for season " + data.seasonName +
                            " by " + sendByDoc.data().name + "." + teamsFuseFooterPlain
                        mailOptions.html = "<img src=\"" + url + "\">You are invited to join <b>" + data.teamName +
                            "</b> for season " + data.seasonName +
                            "</b> by " + sendByDoc.data().name + ". " + teamsFuseFooterHtml;

                        return mailTransport.sendMail(mailOptions);
                    } else {
                        return 12;
                    }
                })
                .then((stuff) => {
                    console.log("Sent email to " + data.email);
                    return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
                })
                .catch((error) => console.error("There was an error while sending the email:", error));
        } else if (data.type === 'InviteType.Player') {
            return Promises.all([
            db.collection("Players").doc(data.playerUid)
                .get(),
                userSentPromise]).then((stuff) => {
                    var snapshot = stuff[0];
                    var sendByDoc = stuff[1];
                    if (snapshot.exists) {
                        const playerData = snapshot.data();

                        var mailOptions = {
                            from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                            to: data.email
                        };

                        mailOptions.subject = "Invitation to join " + playerData.name
                        mailOptions.text = "You are invited to join " + playerData.name +
                            " by " + sendByDoc.data().name + ".  " + teamsFuseFooterPlain
                        mailOptions.html = "You are invited to join <b>" + playerData.name +
                            "</b> by " + sendByDoc.data().name + ".  " + teamsFuseFooterHtml;

                        return mailTransport.sendMail(mailOptions);
                    } else {
                        return 12;
                    }
                })
                .then((stuff) => {
                    console.log("Sent email to " + data.email);
                    return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
                })
                .catch((error) => console.error("There was an error while sending the email:", error));
        } else if (data.type === 'InviteType.LeagueAdmin') {
            userSentPromise.then(sendByDoc => {
                var mailOptionsLeagueAdmin = {
                    from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                    to: data.email
                };
                mailOptionsLeagueAdmin.subject = "Invitation to join TeamsFuse"
                mailOptionsLeagueAdmin.text = "You are invited to join the league " + data.leagueName +
                    " as an admin by " + sendByDoc.data().name + ".  " + teamsFuseFooterPlain;
                mailOptionsLeagueAdmin.html = "You are invited to join the league <b>" + data.leagueName +
                    "</b> as an admin by " + sendByDoc.data().name + ".  " + teamsFuseFooterHtml;

                return mailTransport.sendMail(mailOptionsLeagueAdmin)
            }).then((stuff) => {
                console.log("Sent email to " + data.email);
                return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
            })
            .catch((error) => console.error("There was an error while sending the email:", error));
        } else if (data.type === 'InviteType.Club') {
                userSentPromise.then(sendByDoc => {
                var mailOptionsClub = {
                    from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                    to: data.email
                };

                mailOptionsClub.subject = "Invitation to join club " + data.clubName
                mailOptionsClub.text = "You are invited to join club" + data.clubName +
                    (data.admin ? " as an admin:" : "") +
                    " by " + sendByDoc.data().name +".  " + teamsFuseFooterPlain
                mailOptionsClub.html = "You are invited to join club <b>" + data.clubName +
                    (data.admin ? "</b> as an admin:" : "</b>") +
                    " by " + sendByDoc.data().name + ".  " + teamsFuseFooterHtml;

                return mailTransport.sendMail(mailOptionsClub)
            }).then((stuff) => {
                console.log("Sent email to " + data.email);
                return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
            })
            .catch((error) => console.error("There was an error while sending the email:", error));
        } else if (data.type === 'InviteType.LeagueTeam') {
            userSentPromise.then(sendByDoc => {
                var mailOptionsLeagueTeam = {
                    from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                    to: data.email
                };

                mailOptionsLeagueTeam.subject = "Invitation to join league team " + data.leagueName + ' ' + data.leagueTeamName
                mailOptionsLeagueTeam.text = "You are invited to join league team " + data.leagueName + ' ' + data.leagueTeamName +
                    " by " + sendByDoc.data().name + ".  " + teamsFuseFooterPlain
                mailOptionsLeagueTeam.html = "You are invited to join league team <b>" + data.leagueName + ' ' + data.leagueTeamName +
                    "</b> by " + sendByDoc.data().name + ". " + teamsFuseFooterHtml;

                return mailTransport.sendMail(mailOptionsLeagueTeam)
            }).then((stuff) => {
                console.log("Sent email to " + data.email);
                return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
            })
            .catch((error) => console.error("There was an error while sending the email:", error));
        } else if (data.type === 'InviteType.Admin') {
            return Promises.all([db.collection("Teams").doc(data.teamUid)
                .get(),
                userSentPromise]).then((stuff) => {
                    var snapshot = stuff[0];
                    var sentByDoc = stuff[1];
                    if (snapshot.exists) {
                        const teamData = snapshot.data();

                        var mailOptions = {
                            from: '"' + sendByDoc.data().name + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
                            to: data.email
                        };

                        mailOptions.subject = "Invitation to be an admin for " + teamData.name
                        mailOptions.text = "You are invited to be an admin for " + teamData.name +
                            " by " + sendByDoc.data().name + ".  " + teamsFuseFooterPlain
                        mailOptions.html = "You are invited to be an admin for <b>" + teamData.name +
                            " by " + sendByDoc.data().name + ". " + teamsFuseFooterHtml;

                        return mailTransport.sendMail(mailOptions);
                    } else {
                        return 12;
                    }
                })
                .then((stuff) => {
                    console.log("Sent email to " + data.email);
                    return db.collection("Invites").doc(inputData.after.id).update({emailedInvite: true});
                })
                .catch((error) => console.error("There was an error while sending the email:", error));
        }

        return data;

});
