import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';
import '../messages.dart';
import '../notifications.dart';

/// Creates the text for the game.  THis is used by the game card and other
/// places to display details about the game without being dependent on
/// flutter.
class GameNotification {
  static GameNotification from(BuildContext context, Game game,
      Opponent opponent, Team team, Season season) {
    return GameNotification(
      game,
      team,
      opponent,
      season,
      Messages.of(context),
      MaterialLocalizations.of(context),
      RepositoryProvider.of<Notifications>(context),
    );
  }

  /// Constructor.
  GameNotification(Game g, this.team, this.opponent, this.season, this.messages,
      this.materialLocalizations, this.notification)
      : id = 'Game' + g.uid,
        game = g;

  /// The game to notify about.
  final Game game;

  /// The team to nofify about.
  final Team team;

  /// The opponent to notify about.
  final Opponent opponent;

  /// Season to notify about.
  final Season season;

  /// The notifications setup to use.
  final Notifications notification;

  /// The localization messages to use.
  final Messages messages;

  /// The material locations to use.
  final MaterialLocalizations materialLocalizations;

  /// The id of the notification.
  final String id;

  /// Shows the notification for this game.
  Future<int> showNotification() async {
    StringBuffer body;
    String title;

    final players = <Player>[];

    final gameTime = TimeOfDay.fromDateTime(game.sharedData.tzTime);
    final format = materialLocalizations.formatTimeOfDay(gameTime);
    final timeZone = getLocation(game.sharedData.timezone)
        .timeZone(game.sharedData.time.millisecondsSinceEpoch);
    String endTimeFormat;
    String tzShortName;
    if (game.sharedData.timezone != local.name) {
      tzShortName = timeZone.abbreviation;
    }

    if (game.sharedData.time != game.sharedData.endTime) {
      final endDay = TimeOfDay.fromDateTime(game.sharedData.tzEndTime);
      endTimeFormat = materialLocalizations.formatTimeOfDay(endDay);
    }
    String arriveFormat;
    // Only arrival time for games and only if it is before the game.
    var notifyTime = game.sharedData.tzTime.subtract(Duration(hours: 1));
    if (game.arrivalTime != game.sharedData.time &&
        game.sharedData.type == EventType.Game) {
      final arriveDay = TimeOfDay.fromDateTime(game.tzArriveTime);
      notifyTime = game.tzArriveTime.subtract(Duration(hours: 1));
      arriveFormat = materialLocalizations.formatTimeOfDay(arriveDay);
    }

    if (arriveFormat != null) {
      var address = game.sharedData.place.address;
      if (game.sharedData.place.name.isNotEmpty) {
        address = game.sharedData.place.name;
      }
      body.write(messages.gameAddressArriveAt(arriveFormat, address) + '<br>');
    } else {
      if (game.sharedData.place.name.isNotEmpty) {
        body.write(game.sharedData.place.name + '<br>');
      } else {
        body.write(game.sharedData.place.address + '<br>');
      }
    }
    for (final play in players) {
      body.write('<i>' + messages.nameAndTeam(team.name, play.name) + '</i>');
    }

    switch (game.sharedData.type) {
      case EventType.Game:
        String opName;
        if (opponent == null) {
          opName = messages.unknown;
        } else {
          opName = opponent.name;
        }
        title = messages.gameTitle(format, endTimeFormat, tzShortName, opName);
        break;

      case EventType.Event:
        title = messages.eventTitle(
            format, game.sharedData.name, endTimeFormat, tzShortName);
        break;

      case EventType.Practice:
        title = messages.trainingTitle(format, endTimeFormat, tzShortName);
        break;
    }

    if (game.sharedData.type == EventType.Game) {
      if (game.result.result != GameResult.Unknown) {
        body.write(messages.gameResult(game.result.result));
      }
      if (game.result.inProgress == GameInProgress.Final) {
        body.write(messages.cardResultDetails(game.result));
      } else {
        body.write(messages.gameInProgress(game.result.inProgress));
        body.write(messages.resultInProgress(game.result));
      }
    }

    await notification.zonedSchedule(
      id,
      title,
      body.toString(),
      notifyTime,
    );

    return id.hashCode;
  }

  Future<void> cancel() async {
    await notification.cancelNotification(
      id,
    );
  }
}
