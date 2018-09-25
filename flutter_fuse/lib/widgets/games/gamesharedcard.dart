import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/leagueteamimage.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';
import 'package:flutter_fuse/widgets/games/officalresultdialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/timezone.dart';
import 'dart:async';

class GameSharedCard extends StatelessWidget {
  final GameSharedData game;
  final LeagueOrTournament leagueOrTournament;

  GameSharedCard(this.game)
      : leagueOrTournament =
            UserDatabaseData.instance.leagueOrTournments[game.leagueUid];

  void _editResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    await fullScreenDialog(
      context: context,
      builder: (BuildContext context) {
        return new OfficialResultDialog(game);
      },
    );
  }

  Future<bool> fullScreenDialog({BuildContext context, WidgetBuilder builder}) {
    return Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<bool>(builder: builder, fullscreenDialog: true));
  }

  void _showDirections(BuildContext context) {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(game.place.address);
    if (game.place.placeId != null) {
      url +=
          "&destionation_place_id=" + Uri.encodeComponent(game.place.placeId);
    }
    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = <Widget>[];

    TZDateTime timeNow = new TZDateTime.now(local);
    Duration dur = timeNow.difference(game.tzTime).abs();
    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    String format = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeFormat;
    String tzShortName;
    if (game.timezone != local.name) {
      tzShortName = getLocation(game.timezone).timeZone(game.time.toInt()).abbr;
    }

    print(
        "Times: ${game.time} ${game.endTime} ${game.tzTime} ${game.tzEndTime}");
    if (game.time != game.endTime) {
      TimeOfDay endDay = new TimeOfDay.fromDateTime(game.tzEndTime);
      endTimeFormat = MaterialLocalizations.of(context).formatTimeOfDay(endDay);
    }

    if (game.time <
            timeNow.millisecondsSinceEpoch + Duration.millisecondsPerHour &&
        game.time >
            timeNow.millisecondsSinceEpoch -
                Duration.millisecondsPerHour * 24) {
      // Put in directions buttons.
      buttons.add(
        new FlatButton(
          onPressed: () => _showDirections(context),
          child: new Text(
            Messages.of(context).directionsbuttons,
          ),
        ),
      );
    }

    if (game.time < new DateTime.now().millisecondsSinceEpoch &&
            game.type == EventType.Game &&
            game.officialResults.result == OfficialResult.NotStarted &&
            leagueOrTournament?.isAdmin() ??
        false) {
      // Show a result button (if an admin).
      buttons.add(
        new FlatButton(
          onPressed: () => _editResult(context),
          child: new Text(Messages.of(context).addresultbutton),
        ),
      );
    }

    List<TextSpan> subtitle = <TextSpan>[];
    if (game.place.name.isNotEmpty) {
      subtitle.add(
        new TextSpan(
          style: Theme.of(context).textTheme.subhead,
          text: game.place.name + "\n",
        ),
      );
    } else {
      subtitle.add(
        new TextSpan(
          style: Theme.of(context).textTheme.subhead,
          text: game.place.address + "\n",
        ),
      );
    }

    Color color = Colors.white;
    String title;

    if (game.time < timeNow.millisecondsSinceEpoch && dur.inMinutes < 60) {
      color = Colors.lightBlueAccent;
    }

    TextStyle homeStyle = Theme.of(context).textTheme.body1;
    TextStyle awayStyle = Theme.of(context).textTheme.body1;

    if (game.officialResults.result == OfficialResult.AwayTeamWon) {
      awayStyle =
          awayStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w600);
    }
    if (game.officialResults.result == OfficialResult.HomeTeamWon) {
      homeStyle =
          homeStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w700);
    }

    List<Widget> homeTeamDetails = <Widget>[
      LeagueOrTournamentTeamName(
        game.officialResults.homeTeamLeagueUid,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: homeStyle,
      ),
    ];
    List<Widget> awayTeamDetails = <Widget>[
      LeagueOrTournamentTeamName(
        game.officialResults.awayTeamLeagueUid,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: awayStyle,
      ),
    ];

    switch (game.type) {
      case EventType.Game:
        title = Messages.of(context)
            .gametitleshared(format, endTimeFormat, tzShortName);

        // Add in the offical results.
        if (game.officialResults.result != OfficialResult.NotStarted) {
          TextStyle homeStyle = Theme.of(context)
              .textTheme
              .display1.copyWith(fontSize: 25.0);
          TextStyle awayStyle = Theme.of(context).textTheme.display1.copyWith(fontSize: 25.0);
          if (game.officialResults.result == OfficialResult.AwayTeamWon) {
            awayStyle = awayStyle.copyWith(color: Colors.green);
          }
          if (game.officialResults.result == OfficialResult.HomeTeamWon) {
            homeStyle = homeStyle.copyWith(color: Colors.green);
          }
          if (game.officialResults.scores.containsKey(GamePeriod.regulation)) {
            TextStyle tmpHomeStyle = homeStyle;
            TextStyle tmpAwayStyle = awayStyle;
            if (game.officialResults.scores.length > 1) {
              tmpHomeStyle = homeStyle.copyWith(fontSize: 20.0);
              tmpAwayStyle = awayStyle.copyWith(fontSize: 20.0);
            }
            homeTeamDetails.add(Text(
                game.officialResults.scores[GamePeriod.regulation].score.ptsFor
                    .toString(),
                style: tmpHomeStyle));
            awayTeamDetails.add(Text(
                game.officialResults.scores[GamePeriod.regulation].score
                    .ptsAgainst
                    .toString(),
                style: tmpAwayStyle));
          }
          if (game.officialResults.scores.containsKey(GamePeriod.overtime)) {
            homeTeamDetails.add(Text(
                "OT ${game.officialResults.scores[GamePeriod.overtime].score.ptsFor}",
                style: homeStyle));
            awayTeamDetails.add(Text(
                "OT ${game.officialResults.scores[GamePeriod.overtime].score.ptsAgainst}",
                style: awayStyle));
          }
          if (game.officialResults.scores.containsKey(GamePeriod.penalty)) {
            homeTeamDetails.add(Text(
                "PT ${game.officialResults.scores[GamePeriod.penalty].score.ptsFor}",
                style: homeStyle));
            awayTeamDetails.add(Text(
                "PT ${game.officialResults.scores[GamePeriod.penalty].score.ptsAgainst}",
                style: awayStyle));
          }
        }
        break;

      case EventType.Event:
        title = Messages.of(context)
            .eventtitle(format, game.name, endTimeFormat, tzShortName);

        break;

      case EventType.Practice:
        title = Messages.of(context)
            .trainingtitle(format, endTimeFormat, tzShortName);

        break;
    }
    Widget tile = Container(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pushNamed(context, "/SharedGame/" + game.uid);
            },
            leading: new LeagueTeamImage(
              leagueOrTeamUid: game.officialResults.homeTeamLeagueUid,
              width: 50.0,
              height: 50.0,
              overlay: HomeAwayOverlay.None,
            ),
            title: new Text(
              title,
              overflow: TextOverflow.clip,
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: new RichText(
              text: new TextSpan(
                //style: Theme.of(context).textTheme.subhead,
                children: subtitle,
              ),
            ),
            trailing: new LeagueTeamImage(
              leagueOrTeamUid: game.officialResults.awayTeamLeagueUid,
              width: 50.0,
              height: 50.0,
              overlay: HomeAwayOverlay.None,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: homeTeamDetails,
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: awayTeamDetails,
                ),
              )
            ],
          )
        ],
      ),
    );
    if (buttons.length > 0) {
      return new Card(
        color: color,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            tile,
            new ButtonTheme.bar(
              // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: buttons,
              ),
            ),
          ],
        ),
      );
    } else {
      return new Card(
        color: color,
        child: tile,
      );
    }
  }
}
