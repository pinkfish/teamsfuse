import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../games/officalresultdialog.dart';
import '../leagueortournament/leagueortournamentteamname.dart';
import '../leagueortournament/leagueteamimage.dart';

///
/// The shared details of the game.
///
class GameSharedCard extends StatelessWidget {
  /// Constructor
  GameSharedCard(this.game);

  /// The game shared details to look at.
  final GameSharedData game;

  void _editResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    await _fullScreenDialog(
      context: context,
      builder: (context) {
        return OfficialResultDialog(game);
      },
    );
  }

  Future<bool> _fullScreenDialog(
      {BuildContext context, WidgetBuilder builder}) {
    return Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<bool>(builder: builder, fullscreenDialog: true));
  }

  void _showDirections(BuildContext context) {
    var url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=${Uri.encodeComponent(game.place.address)}";
    if (game.place.placeId != null) {
      url +=
          "&destionation_place_id=${Uri.encodeComponent(game.place.placeId)}";
    }
    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];

    var timeNow = TZDateTime.now(local);
    var dur = timeNow.difference(game.tzTime).abs();
    var day = TimeOfDay.fromDateTime(game.tzTime);
    var format = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeFormat;
    String tzShortName;
    if (game.timezone != local.name) {
      tzShortName = getLocation(game.timezone)
          .timeZone(game.time.millisecondsSinceEpoch)
          .abbr;
    }

    print(
        "Times: ${game.time} ${game.endTime} ${game.tzTime} ${game.tzEndTime}");
    if (game.time != game.endTime) {
      var endDay = TimeOfDay.fromDateTime(game.tzEndTime);
      endTimeFormat = MaterialLocalizations.of(context).formatTimeOfDay(endDay);
    }

    if (game.time.isBefore(timeNow
            .add(Duration(milliseconds: Duration.millisecondsPerHour))) &&
        game.time.isAfter(timeNow.subtract(
            Duration(milliseconds: Duration.millisecondsPerHour * 24)))) {
      // Put in directions buttons.
      buttons.add(
        FlatButton(
          onPressed: () => _showDirections(context),
          child: Text(
            Messages.of(context).directionsbuttons,
          ),
        ),
      );
    }

    LeagueOrTournament leagueOrTournament;
    var leagueOrTournamentBloc =
        BlocProvider.of<LeagueOrTournamentBloc>(context);
    if (leagueOrTournamentBloc.state.leagueOrTournaments
        .containsValue(game.leagueUid)) {
      leagueOrTournament =
          leagueOrTournamentBloc.state.leagueOrTournaments[game.leagueUid];
    }
    if (game.time.isBefore(DateTime.now()) &&
        game.type == EventType.Game &&
        game.officialResult.result == OfficialResult.NotStarted &&
        (leagueOrTournament?.isAdmin() ?? false)) {
      // Show a result button (if an admin).
      buttons.add(
        TextButton(
          onPressed: () => _editResult(context),
          child: Text(Messages.of(context).addResultButton),
        ),
      );
    }

    var subtitle = <TextSpan>[];
    if (game.place.name.isNotEmpty) {
      subtitle.add(
        TextSpan(
          style: Theme.of(context).textTheme.subtitle1,
          text: "${game.place.name}\n",
        ),
      );
    } else {
      subtitle.add(
        TextSpan(
          style: Theme.of(context).textTheme.subtitle1,
          text: "${game.place.address}\n",
        ),
      );
    }

    var color = Colors.white;
    String title;

    if (game.time.isBefore(timeNow) && dur.inMinutes < 60) {
      color = Colors.lightBlueAccent;
    }

    var homeStyle = Theme.of(context).textTheme.bodyText2;
    var awayStyle = Theme.of(context).textTheme.bodyText2;

    if (game.officialResult.result == OfficialResult.AwayTeamWon) {
      awayStyle =
          awayStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w600);
    }
    if (game.officialResult.result == OfficialResult.HomeTeamWon) {
      homeStyle =
          homeStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w700);
    }

    var homeTeamDetails = <Widget>[
      game.officialResult.homeTeamLeagueUid == null
          ? Text(Messages.of(context).unknown)
          :LeagueOrTournamentTeamName(
        game.officialResult.homeTeamLeagueUid,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: homeStyle,
      ),
    ];
    var awayTeamDetails = <Widget>[
      game.officialResult.awayTeamLeagueUid == null
          ? Text(Messages.of(context).unknown)
          : LeagueOrTournamentTeamName(
              game.officialResult.awayTeamLeagueUid,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: awayStyle,
            ),
    ];

    switch (game.type) {
      case EventType.Game:
        title = Messages.of(context)
            .gameTitleShared(format, endTimeFormat, tzShortName);

        // Add in the offical results.
        if (game.officialResult.result != OfficialResult.NotStarted) {
          var homeStyle =
              Theme.of(context).textTheme.headline4.copyWith(fontSize: 25.0);
          var awayStyle =
              Theme.of(context).textTheme.headline4.copyWith(fontSize: 25.0);
          if (game.officialResult.result == OfficialResult.AwayTeamWon) {
            awayStyle = awayStyle.copyWith(color: Colors.green);
          }
          if (game.officialResult.result == OfficialResult.HomeTeamWon) {
            homeStyle = homeStyle.copyWith(color: Colors.green);
          }
          if (game.officialResult.scores.containsKey(GamePeriod.regulation1)) {
            var tmpHomeStyle = homeStyle;
            var tmpAwayStyle = awayStyle;
            if (game.officialResult.scores.length > 1) {
              tmpHomeStyle = homeStyle.copyWith(fontSize: 20.0);
              tmpAwayStyle = awayStyle.copyWith(fontSize: 20.0);
            }
            homeTeamDetails.add(Text(
                game.officialResult.scores[GamePeriod.regulation1].score.ptsFor
                    .toString(),
                style: tmpHomeStyle));
            awayTeamDetails.add(Text(
                game.officialResult.scores[GamePeriod.regulation1].score
                    .ptsAgainst
                    .toString(),
                style: tmpAwayStyle));
          }
          if (game.officialResult.scores.containsKey(GamePeriod.overtime1)) {
            homeTeamDetails.add(Text(
                "OT ${game.officialResult.scores[GamePeriod.overtime1].score.ptsFor}",
                style: homeStyle));
            awayTeamDetails.add(Text(
                "OT ${game.officialResult.scores[GamePeriod.overtime1].score.ptsAgainst}",
                style: awayStyle));
          }
          if (game.officialResult.scores.containsKey(GamePeriod.penalty)) {
            homeTeamDetails.add(Text(
                "PT ${game.officialResult.scores[GamePeriod.penalty].score.ptsFor}",
                style: homeStyle));
            awayTeamDetails.add(Text(
                "PT ${game.officialResult.scores[GamePeriod.penalty].score.ptsAgainst}",
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
    print("Shared Game ${game.uid}");
    Widget tile = Container(
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pushNamed(context, "/SharedGame/${game.uid}");
            },
            leading: game.officialResult.homeTeamLeagueUid == null
                ? Icon(MdiIcons.skullCrossbones)
                : LeagueTeamImage(
                    leagueOrTeamUid: game.officialResult.homeTeamLeagueUid,
                    width: 50.0,
                    height: 50.0,
                    overlay: HomeAwayOverlay.none,
                  ),
            title: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: RichText(
              text: TextSpan(
                //style: Theme.of(context).textThemesubtitle1,
                children: subtitle,
              ),
            ),
            trailing: game.officialResult.awayTeamLeagueUid == null
                ? Icon(MdiIcons.skullCrossbones)
                : LeagueTeamImage(
                    leagueOrTeamUid: game.officialResult.awayTeamLeagueUid,
                    width: 50.0,
                    height: 50.0,
                    overlay: HomeAwayOverlay.none,
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
      return Card(
        color: color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            tile,
            ButtonBarTheme(
              // make buttons use the appropriate styles for cards
              child: ButtonBar(
                children: buttons,
              ),
            ),
          ],
        ),
      );
    } else {
      return Card(
        color: color,
        child: tile,
      );
    }
  }
}
