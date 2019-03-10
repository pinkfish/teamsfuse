"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const notifyforgame = require("../util/notifyforgame");
const moment = require("moment-timezone");

var db = admin.firestore();

exports = module.exports = functions.firestore
  .document("/Games/{gameid}")
  .onUpdate((inputData, context) => {
    const data = inputData.after.data();
    var previousData = inputData.before.data();

    // Check to see if there is any result at all yet.
    if (data.result === null) {
      // No results.
      console.log("No results");
      return data;
    }

    if (previousData === null) {
      previousData = {};
    }
    if (previousData.result === null) {
      previousData.result = {
        scores: {}
      };
    }

    console.log(
      "Start " +
        data.result.inProgress +
        " " +
        data.result.result +
        " -- " +
        previousData.result.result
    );
    // Loop through the values on scores.
    var diff = false;
    var diffScoreTypes = [];
    var curScores = data.result.scores["Regulation"];
    var result = 0;
    if (previousData.result === null) {
      previousData.result = {
        scores: {}
      };
    }
    if (curScores === null) {
      curScores = { ptsFor: 0, ptsAgainst: 0 };
    }
    //var currentScoreStr = '';
    for (var s in data.result.scores) {
      if (data.result.scores.hasOwnProperty(s)) {
        var nowScore = data.result.scores[s];
        var beforeScore = previousData.result.scores[s];
        console.log(nowScore);
        console.log(s);
        console.log(beforeScore);
        if (beforeScore === null || typeof beforeScore === "undefined") {
          diff = true;
          diffScoreTypes.push(s);
          //currentScoreStr = currentScoreStr + s + ' ' + ptsFor + ' - ' + ptsAgainst + '\n';
        } else if (
          beforeScore.ptsAgainst !== nowScore.ptsAgainst ||
          beforeScore.ptsFor !== nowScore.ptsFor
        ) {
          diff = true;
          diffScoreTypes.push(s);
          //currentScoreStr = currentScoreStr + s + ' ' + ptsFor + ' - ' + ptsAgainst + '\n';
        }
        if (nowScore.ptsFor > nowScore.ptsAgainst) {
          curScores = nowScore;
          result = 1;
        } else if (nowScore.ptsFor < nowScore.ptsAgainst) {
          curScores = nowScore;
          result = 2;
        }
      }
    }
    if (
      data.result.inProgress !== "GameInProgress.NotStarted" &&
      (data.result.inProgress !== previousData.result.inProgress ||
        diff ||
        data.result.result !== previousData.result.result)
    ) {
      var userId;
      // If we are authenticated then don't tell the person doing the
      // update about this change.
      if (context.auth) {
        userId = context.auth.uid;
      }
      console.log(data.result);
      console.log(curScores);
      var mess = "";
      if (data.result.inProgress === "GameInProgrsss.Final") {
        if (result === 0) {
          console.log(data.result);
          console.log(curScores);
          mess = "Tied at end of game";
        } else if (result === 1) {
          mess = "Won the game";
        } else {
          mess = "Lost the game";
        }
      } else {
        var inProgress = "";
        if (data.result.period.startsWith("Overtime")) {
          inProgress = " in overtime";
        } else if (data.result.period.startsWith("Penalty")) {
          inProgress = " in penalty shootout";
        }
        if (result === 0) {
          mess = "Game tied" + inProgress;
        } else if (result === 1) {
          mess = "Winning game" + inProgress;
        } else {
          mess = "Losing game" + inProgress;
        }
      }

      var payload = {
        notification: {
          title:
            "{{opponent.name}} " +
            curScores.ptsFor +
            " - " +
            curScores.ptsAgainst,
          body: mess,
          clickAction: "GAMERESULT",
          tag: inputData.after.id + "result"
        }
      };

      payload["options"] = {
        collapse_key: inputData.after.id + "result",
        timeToLive: 259200 // Keep for three days.
      };

      console.log("Notifying about");
      console.log(payload);

      return notifyforgame.notifyForGame(
        inputData.after,
        payload,
        userId,
        true
      );
    }
    return data;
  });
