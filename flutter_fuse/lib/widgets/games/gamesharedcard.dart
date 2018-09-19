import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/leagueteamimage.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/timezone.dart';

class GameSharedCard extends StatelessWidget {
  final GameSharedData game;
  final LeagueOrTournament leagueOrTournament;

  GameSharedCard(this.game)
      : leagueOrTournament =
            UserDatabaseData.instance.leagueOrTournments[game.leagueUid];

  void _editResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 0.0,
          width: 0.0,
        );
        //return new EditResultDialog(game);
      },
    );
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

    print("Times: ${game.time} ${game.endTime} ${game.tzTime} ${game.tzEndTime}");
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
            game.officalResults == OfficalResult.NotStarted &&
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

    switch (game.type) {
      case EventType.Game:
        title = Messages.of(context)
            .gametitleshared(format, endTimeFormat, tzShortName);

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
    Widget tile = Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/SharedGame/" + game.uid);
          },
          leading: new LeagueTeamImage(
            leagueOrTeamUid: game.officalResults.homeTeamLeagueUid,
            width: 50.0,
            height: 50.0,
            overlay: HomeAwayOverlay.Home,
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
            leagueOrTeamUid: game.officalResults.awayTeamLeagueUid,
            width: 50.0,
            height: 50.0,
            overlay: HomeAwayOverlay.Away,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: LeagueOrTournamentTeamName(
                  game.officalResults.homeTeamLeagueUid,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: LeagueOrTournamentTeamName(
                game.officalResults.awayTeamLeagueUid,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        )
      ],
    );
    if (buttons.length > 0) {
      return new Card(
        color: color,
        child: new Column(
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
