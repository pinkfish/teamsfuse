"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");

var db = admin.firestore();
let FieldValue = require('firebase-admin').firestore.FieldValue;


exports = module.exports = functions.firestore
  .document("/Players/{playerid}")
  .onWrite((inputData, context) => {
  const data = inputData.after.data();
  const previousData = inputData.before.data();

    // If we have a new user, update this everywhere.
    var ret = [];
    for (var user in data.user) {
      if (!(user in previousData.user)) {
        ret.push(addUser(user));
      }
    }
    for (user in previousData.user) {
      if (!(user in data.user)) {
        ret.push(removeUser(user));
      }
    }

    return Promise.all(ret);
  });

  function addUser(user){
      // Add this user everywhere.
      return db.collection("Seasons").where("players." + inputData.after.id + ".added", "==", true).get()
          .then(snapshot => {
            var innerRet = [];
            snapshot.docs.forEach(doc => {
              var updateData = {}
              updateData["users." + user + ".added"] = true;
              updateData["users." + user + "." + inputData.after.id] = true;
              innerRet.push(db.collection("Seasons").doc(doc.id).update(updateData));
              innerRet.push(db.collection("Teams").doc(doc.data().teamUid).update(updateData));
            });
            return Promise.all(innerRet);
          });
  }

  function removeUser(user) {
      // Delete this user everywhere.
      return db.collection("Seasons").where("players." +  inputData.after.id + ".added", "==", true).get()
          .then(snapshot => {
            var innerRet = [];
            snapshot.docs.forEach(doc => {
              // Remove the player from the set.
              var found = false;
              for (var idx in doc.data().users[user]) {
                if (idx !== "added" && idx !== inputData.after.id) {
                  found = true;
                }
              }
              // Remove just the player, or everything.
              var updateData = {}
              updateData["users." + user + "." + inputData.after.id] =  FieldValue.delete();
              innerRet.push(db.collection("Seasons").doc(doc.id).update(updateData));
              innerRet.push(db.collection("Teams").doc(doc.data().teamUid).update(updateData));
             });
            return Promise.all(innerRet);
          });
  }
