"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const gamenotifypayload = require("./gamenotifypayload");
const moment = require("moment-timezone");

var db = admin.firestore();

exports = module.exports = functions.firestore
  .document("/Games/{gameid}")
  .onDelete((snap, context) => {
    const data = snap.data();

    // Only notify if less then 7 days before the event.
    var arrivalTime = moment(data.arrivalTime);
    var nowTime = moment();
    var diff = arrivalTime.diff(nowTime, "days");
    var payload = null;
    console.log("on change " + snap.id + " diff " + diff);
    if (diff <= 7 && nowTime.valueOf() < data.time) {
      console.log("Changed in here");
      // Notify the user of the new event/training/game.
      if (data.type === "EventType.Practice") {
        payload = {
          notification: {
            title: "DELETE practice for {{team.name}}",
            body: "Delete practice at {[arrivalTime}}"
          }
        };
      } else if (data.type === "EventType.Game") {
        payload = {
          notification: {
            title: "DELETE Game vs {{opponent.name}}",
            body: "Delete game at {{arrivalTime}}"
          }
        };
      } else if (data.type === "EventType.Event") {
        payload = {
          notification: {
            title: "DELETE event for {{team.name}}",
            body: "Delete event at {{arrivalTime}}"
          }
        };
      }
    }

    if (payload) {
      return gamenotifypayload.notifyPayload(payload, snap);
    }
    return data;
  });
