"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");

var db = admin.firestore();

exports = module.exports = functions.firestore
  .document("/MessageRecipients/{messageid}")
  .onWrite((inputData, context) => {
    const data = inputData.after.data();
    const previousData = data.before.data();

    // See if the name is different.
    if (data.userId !== previousData.userId) {
      console.log(
        "checking for duplicates " + data.userId + " " + data.messageId
      );
      // Update everywhere.
      return db
        .collection("MessageRecipients")
        .where("userId", "==", data.userId)
        .where("messageId", "==", data.messageId)
        .get()
        .then(snapshot => {
          console.log("checking for duplicates " + snapshot.docs.length);

          var docsStuff = [];
          if (snapshot.docs.length > 1) {
            // Set userid to 'ignore' and archived.
            docsStuff.push(
              inputData.after.ref.update(
                {
                  state: "MesasageState.Archived",
                  userId: "ignore"
                },
                { merge: true }
              )
            );
          }
          return Promise.all(docsStuff);
        });
    }

    return data;
  });
