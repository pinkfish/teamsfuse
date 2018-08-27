'use strict';

const admin = require('firebase-admin');
const functions = require('firebase-functions');

var db = admin.firestore();


exports = module.exports = functions.firestore.document("/MessageRecipients/{messageid}")
    .onWrite((inputData, context) => {
        const data = inputData.after.data();
        const previousData = data.before.data();

        // See if the name is different.
        if (data.userId === null) {
            console.log('new message!', data.after.id);
            // Update everywhere.
            return db.collection("Players").doc(data.playerId)
                .get()
                .then(snapshot => {
                    var docsStuff = []
                    if (snapshot.exists) {
                        const users = snapshot.data().user;
                        var setupFirst = false;
                        console.log(snapshot.data());
                        console.log(users);
                        for (var userId in users) {
                            console.log('Checking ' + userId);
                            if (users.hasOwnProperty(userId)) {
                                if (!setupFirst) {
                                    console.log('Updating first ' + userId);
                                    setupFirst = true;
                                    data.userId = userId;
                                    docsStuff.push(inputData.after.ref.set({
                                        userId: userId
                                    }, {
                                        merge: true
                                    }));
                                    // Send email.
                                } else {
                                    // Make a copy and fill in the details with the new user.
                                    // Only do this if there is not already a messageid tracked for
                                    // this user.

                                    var promise =
                                        db.collection("MessageRecipients")
                                        .where("userId", "==", userId)
                                        .where("messageId", "==", data.messageId)
                                        .get();

                                    docsStuff.push(promise);
                                }
                            }
                        }
                    }
                    return Promise.all(docsStuff);
                })
                .then(allSnaps => {
                    var allUpdates = [];
                    for (key in allSnaps) {
                        var snap = allSnaps[key];
                        console.log('Making a copy ' + userId + " " + snap.docs.length);
                        if (snap.docs.length === 0) {
                            console.log('zero count');
                            data.userId = userId;
                            allUpdates.push(db.collection("MessageRecipients").add(data));
                            // Send email.
                        }
                    }
                    return Promise.all(allUpdates);
                });
        }

        return data;
    });