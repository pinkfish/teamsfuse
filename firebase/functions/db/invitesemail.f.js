'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const mailTransport = require('../util/mailgun')
var db = admin.firestore();

// Sends an email confirmation when a user changes his mailing list subscription.
exports = module.exports = functions.firestore.document('/Invites/{id}').onWrite((inputData, context) => {
    const data = inputData.after.data();

    // Already emailed about this invite.
    if (data.emailedInvite) {
        return null;
    }
    if (data.type === 'InviteType.Team') {
        // Find the team details.
        return db.collection("Teams")
            .doc(data.teamUid)
            .get()
            .then(snapshot => {
                if (snapshot.exists) {
                    const teamData = snapshot.data();
                    var mailOptions = {
                        from: '"' + data.displayName + '" <' + data.sentbyUid + '@email.teamsfuse.com>',
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
                        " by " + data.displayName + ".  TeamsFuse is an app to help " +
                        "organize your sports team."
                    mailOptions.html = "You are invited to join <b>" + data.teamName +
                        "</b> for season " + data.seasonName +
                        "</b> by " + data.displayName +".  <i>TeamsFuse</I> is an app to " +
                        "help organize your sports teams.<p><img src='" + url + "' />";

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
        return db.collection("Players").doc(data.playerUid)
            .get()
            .then((snapshot) => {
                if (snapshot.exists) {
                    const playerData = snapshot.data();

                    var mailOptions = {
                        from: '"' + data.displayName + '" <' + data.sentByUid + '@email.teamsfuse.com>',
                        to: data.email
                    };

                    mailOptions.subject = "Invitation to join " + playerData.name
                    mailOptions.text = "You are invited to join " + playerData.name +
                        ".  TeamsFuse is an app to help " +
                        "organize your sports team."
                    mailOptions.html = "You are invited to join <b>" + playerData.name +
                        ".  <i>TeamsFuse</I> is an app to " +
                        "help organize your sports teams.<p>";

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
    } else if (data.type === 'InviteType.Admin') {
        return db.collection("Teams").doc(data.teamUid)
            .get()
            .then((snapshot) => {
                if (snapshot.exists) {
                    const teamData = snapshot.data();

                    var mailOptions = {
                        from: '"' + data.displayName + '" <' + data.sentByUid + '@email.teamsfuse.com>',
                        to: data.email
                    };

                    mailOptions.subject = "Invitation to be an admin for " + teamData.name
                    mailOptions.text = "You are invited to be an admin for " + teamData.name +
                        ".  TeamsFuse is an app to help " +
                        "organize your sports team."
                    mailOptions.html = "You are invited to be an admin for <b>" + teamData.name +
                        ".  <i>TeamsFuse</I> is an app to " +
                        "help organize your sports teams.<p><img src='" + url + "' />";

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
