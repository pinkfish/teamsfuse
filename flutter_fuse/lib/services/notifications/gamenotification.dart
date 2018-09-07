import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Creates the text for the game.  THis is used by the game card and other
// places to display details about the game without being dependent on
// flutter.
class GameNotification {
  final Game game;
  final Team team;

  GameNotification(this.game, this.team);

  Future<int> showNotification(
      int id,
      FlutterLocalNotificationsPlugin notification,
      Messages messages,
      MaterialLocalizations materialLocalizations) async {
    /*
    StringBuffer body;
    String title;

    Opponent op;
    if (team == null || !team.opponents.containsKey(game.opponentUid)) {
      op = new Opponent(name: messages.unknown);
    } else {
      op = team.opponents[game.opponentUid];
    }

    List<Player> players = <Player>[];
    Season season;
    if (team != null) {
      season = team.seasons[game.seasonUid];
    }
    if (season == null) {
      season = new Season();
    }

    TZDateTime timeNow = new TZDateTime.now(local);
    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    String format = materialLocalizations.formatTimeOfDay(day);
    String endTimeFormat;
    String tzShortName;
    if (game.timezone != local.name) {
      tzShortName = getLocation(game.timezone).timeZone(game.time.toInt()).abbr;
    }

    if (game.time != game.endTime) {
      TimeOfDay endDay = new TimeOfDay.fromDateTime(game.tzEndTime);
      endTimeFormat = materialLocalizations.formatTimeOfDay(endDay);
    }
    String arriveFormat;
    // Only arrival time for games and only if it is before the game.
    if (game.arriveTime != game.time &&
        game.type == EventType.Game &&
        timeNow.millisecondsSinceEpoch <
            game.arriveTime + Duration.millisecondsPerHour) {
      TimeOfDay arriveDay = new TimeOfDay.fromDateTime(game.tzArriveTime);
      arriveFormat = materialLocalizations.formatTimeOfDay(arriveDay);
    }

    if (arriveFormat != null) {
      String addr = game.place.address;
      if (game.place.name.isNotEmpty) {
        addr = game.place.name;
      }
      body.write(messages.gameaddressarriveat(arriveFormat, addr) + "<br>");
    } else {
      if (game.place.name.isNotEmpty) {
        body.write(game.place.name + "<br>");
      } else {
        body.write(game.place.address + "<br>");
      }
    }
    for (Player play in players) {
      body.write("<i>" + messages.nameandteam(team, play) + "</i>");
    }

    switch (game.type) {
      case EventType.Game:
        String opName;
        if (op == null) {
          opName = messages.unknown;
        } else {
          opName = op.name;
        }
        title = messages.gametitle(format, endTimeFormat, tzShortName, opName);
        break;

      case EventType.Event:
        title =
            messages.eventtitle(format, game.name, endTimeFormat, tzShortName);
        break;

      case EventType.Practice:
        title = messages.trainingtitle(format, endTimeFormat, tzShortName);
        break;
    }

    if (game.type == EventType.Game) {
      if (game.result.result != GameResult.Unknown) {
        body.write(messages.gameresult(game.result.result));
      }
      if (game.result.inProgress == GameInProgress.Final) {
        /*
        GameResultPerPeriod finalResult;
        GameResultPerPeriod overtimeResult;
        if (game.result.scores.containsKey(GameInProgress.Overtime)) {
          overtimeResult = game.result.scores[GameInProgress.Overtime];
        }
        GameResultPerPeriod penaltyResult;
        if (game.result.scores.containsKey(GameInProgress.Penalty)) {
          penaltyResult = game.result.scores[GameInProgress.Penalty];
        }
        body += "${finalResult.score.ptsFor} - ${finalResult.score.ptsAgainst}";
        if (overtimeResult != null) {
          body += "OT ${overtimeResult.score.ptsFor} - ${overtimeResult.score
              .ptsAgainst}";
        }
        if (penaltyResult != null) {
          body += "PT ${penaltyResult.score.ptsFor} - ${penaltyResult.score
              .ptsAgainst}";
        }
        */
      } else {
        body.write(messages.gameinprogress(game.result.inProgress));
        body.write(messages.resultinprogress(game.result));
      }
    }

    NotificationDetailsAndroid android =
        new NotificationDetailsAndroid("Game", "Games", "Games notifications");
    NotificationDetailsIOS iOS = new NotificationDetailsIOS();
    NotificationDetails details = new NotificationDetails(android, iOS);
    print("$title $body $details");
    /*
    if (game.arriveTime > scheduleToShow) {
      await notification.show(id, title, body, details);
    } else {
      await notification.schedule(id, title, body,
          new DateTime.fromMillisecondsSinceEpoch(scheduleToShow), details);
    }
    */
    */
    return id;
  }
}
