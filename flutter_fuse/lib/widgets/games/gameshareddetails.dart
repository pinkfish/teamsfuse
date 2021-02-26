import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../leagueortournament/leagueimage.dart';
import '../leagueortournament/leagueortournamentname.dart';
import '../leagueortournament/leagueortournamentteamname.dart';
import '../leagueortournament/leagueteamimage.dart';
import 'gamemapview.dart';
import 'officalresultdialog.dart';

///
/// Display the shared details for the game.
///
class GameSharedDetails extends StatefulWidget {
  /// Constructor.
  GameSharedDetails(this.game, {this.adding = false});

  /// The game to show the details of.
  final GameSharedData game;

  /// If we are adding this game.
  final bool adding;

  @override
  _GameSharedDetailsState createState() {
    return _GameSharedDetailsState();
  }
}

class _GameSharedDetailsState extends State<GameSharedDetails> {
  StreamSubscription<UpdateReason> teamUpdate;
  StreamSubscription<UpdateReason> _subscription;

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
    teamUpdate?.cancel();
    teamUpdate = null;
  }

  void _openNavigation() {
    var url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=${Uri.encodeComponent(widget.game.place.address)}";
    if (widget.game.place.placeId != null) {
      url +=
          "&destination_place_id=${Uri.encodeComponent(widget.game.place.placeId)}";
    }
    launch(url);
  }

  void _editResult() async {
    // Call up a dialog to edit the result.
    await _fullScreenDialog(
      context: context,
      builder: (context) {
        return OfficialResultDialog(widget.game);
      },
    );
  }

  Future<bool> _fullScreenDialog(
      {BuildContext context, WidgetBuilder builder}) {
    return Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<bool>(builder: builder, fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    var day = TimeOfDay.fromDateTime(widget.game.tzTime);
    var dayEnd = TimeOfDay.fromDateTime(widget.game.tzEndTime);
    var dateStr =
        MaterialLocalizations.of(context).formatFullDate(widget.game.tzTime);
    var timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    var endTimeStr = MaterialLocalizations.of(context).formatTimeOfDay(dayEnd);
    String tzShortName;
    if (widget.game.timezone != local.name) {
      var abbr = getLocation(widget.game.timezone)
          .timeZone(widget.game.time.millisecondsSinceEpoch)
          .abbr;
      tzShortName = " ($abbr)";
    }

    var theme = Theme.of(context);

    var body = <Widget>[];
    // Map view.
    body.add(
      Container(
        height: 250.0,
        child: Stack(
          children: <Widget>[
            Center(
              child: GameMapView(widget.game),
            ),
            Positioned(
              right: 20.0,
              bottom: 0.0,
              child: FloatingActionButton(
                onPressed: _openNavigation,
                child: const Icon(Icons.directions),
                backgroundColor: Colors.orange,
                heroTag: widget.game.uid,
              ),
            ),
          ],
        ),
      ),
    );

    // League details
    var homeStyle = Theme.of(context).textTheme.subtitle1;
    var awayStyle = Theme.of(context).textTheme.subtitle1;

    if (widget.game.officialResult.result == OfficialResult.AwayTeamWon) {
      awayStyle =
          awayStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w600);
    }
    if (widget.game.officialResult.result == OfficialResult.HomeTeamWon) {
      homeStyle =
          homeStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w700);
    }
    var homeTeamDetails = <Widget>[
      Align(
        alignment: Alignment.topRight,
        child: LeagueTeamImage(
          leagueOrTeamUid: widget.game.officialResult.homeTeamLeagueUid,
          width: 50.0,
          height: 50.0,
        ),
      ),
      LeagueOrTournamentTeamName(
        widget.game.officialResult.homeTeamLeagueUid,
        style: homeStyle,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
      )
    ];

    var awayTeamDetails = <Widget>[
      Align(
        alignment: Alignment.topLeft,
        child: LeagueTeamImage(
          leagueOrTeamUid: widget.game.officialResult.awayTeamLeagueUid,
          width: 50.0,
          height: 50.0,
        ),
      ),
      LeagueOrTournamentTeamName(
        widget.game.officialResult.awayTeamLeagueUid,
        style: awayStyle,
        overflow: TextOverflow.ellipsis,
      )
    ];

    if (widget.game.type == EventType.Game &&
        widget.game.officialResult.result != OfficialResult.NotStarted) {
      var homeStyle =
          Theme.of(context).textTheme.headline4.copyWith(fontSize: 25.0);
      var awayStyle =
          Theme.of(context).textTheme.headline4.copyWith(fontSize: 25.0);
      if (widget.game.officialResult.result == OfficialResult.AwayTeamWon) {
        awayStyle = awayStyle.copyWith(color: Colors.green);
      }
      if (widget.game.officialResult.result == OfficialResult.HomeTeamWon) {
        homeStyle = homeStyle.copyWith(color: Colors.green);
      }
      if (widget.game.officialResult.scores
          .containsKey(GamePeriod.regulation1)) {
        var tmpHomeStyle = homeStyle;
        var tmpAwayStyle = awayStyle;
        if (widget.game.officialResult.scores.length > 1) {
          tmpHomeStyle = homeStyle.copyWith(fontSize: 20.0);
          tmpAwayStyle = awayStyle.copyWith(fontSize: 20.0);
        }
        homeTeamDetails.add(Text(
          widget.game.officialResult.scores[GamePeriod.regulation1].score.ptsFor
              .toString(),
          style: tmpHomeStyle,
          textAlign: TextAlign.end,
        ));
        awayTeamDetails.add(Text(
          widget.game.officialResult.scores[GamePeriod.regulation1].score
              .ptsAgainst
              .toString(),
          style: tmpAwayStyle,
          textAlign: TextAlign.start,
        ));
      }
      if (widget.game.officialResult.scores.containsKey(GamePeriod.overtime1)) {
        homeTeamDetails.add(Text(
          "OT ${widget.game.officialResult.scores[GamePeriod.overtime1].score.ptsFor}",
          style: homeStyle,
          textAlign: TextAlign.end,
        ));
        awayTeamDetails.add(Text(
          "OT ${widget.game.officialResult.scores[GamePeriod.overtime1].score.ptsAgainst}",
          style: awayStyle,
          textAlign: TextAlign.start,
        ));
      }
      if (widget.game.officialResult.scores.containsKey(GamePeriod.penalty)) {
        homeTeamDetails.add(Text(
          "PT ${widget.game.officialResult.scores[GamePeriod.penalty].score.ptsFor}",
          style: homeStyle,
          textAlign: TextAlign.end,
        ));
        awayTeamDetails.add(Text(
          "PT ${widget.game.officialResult.scores[GamePeriod.penalty].score.ptsAgainst}",
          style: awayStyle,
          textAlign: TextAlign.start,
        ));
      }
    }
    body.add(
      Container(
        margin: EdgeInsets.only(left: 5.0, right: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: homeTeamDetails,
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 50.0,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                'vs',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: awayTeamDetails,
              ),
            ),
          ],
        ),
      ),
    );

    body.add(SizedBox(height: 10.0));

    // Map details
    var lastBit = (widget.game.endTime == widget.game.time
        ? ''
        : " - ${endTimeStr + (tzShortName ?? '')}");
    body.add(
      ListTile(
        leading: Icon(Icons.directions),
        title: Text(
          "$dateStr $timeStr$lastBit",
          style: theme.textTheme.subtitle1.copyWith(color: theme.accentColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.game.place.name ?? ''),
            Text(widget.game.place.address ?? Messages.of(context).unknown),
          ],
        ),
      ),
    );

    // Results.
    if (widget.game.type == EventType.Game) {
      if (widget.adding) {
        body.add(
          ListTile(
            leading: Icon(MdiIcons.bookOpenVariant),
            title: Text(Messages.of(context).gametype),
          ),
        );
      } else {
        String title;

        // Started.
        switch (widget.game.officialResult.result) {
          case OfficialResult.NotStarted:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResult.result);
            break;
          case OfficialResult.InProgress:
            if (widget.game.officialResult.result !=
                OfficialResult.NotStarted) {
              title = Messages.of(context)
                  .gameofficalinprogress(widget.game.officialResult.result);
            } else {
              title = Messages.of(context).noResult;
            }
            break;
          case OfficialResult.HomeTeamWon:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResult.result);
            break;
          case OfficialResult.AwayTeamWon:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResult.result);
            break;
          case OfficialResult.Tie:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResult.result);
            break;
        }
        body.add(
          ListTile(
            onTap: _editResult,
            leading: LeagueImage(
              leagueOrTournamentUid: widget.game.leagueUid,
              width: 40.0,
              height: 40.0,
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: LeagueOrTournamentName(
                widget.game.leagueUid,
                textAlign: TextAlign.start,
              ),
            ),
            subtitle: Text(
              title,
              textAlign: TextAlign.start,
            ),
          ),
        );
        LeagueOrTournament leagueOrTournament;
        var leagueOrTournamentBloc =
            BlocProvider.of<LeagueOrTournamentBloc>(context);
        if (leagueOrTournamentBloc.state.leagueOrTournaments
            .containsValue(widget.game.leagueUid)) {
          leagueOrTournament = leagueOrTournamentBloc
              .state.leagueOrTournaments[widget.game.leagueUid];
        }
        if (leagueOrTournament?.isAdmin() ?? false) {
          body.add(ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text(Messages.of(context).editbuttontext),
                onPressed: _editResult,
              ),
            ],
          ));
        }
      }
    } else {
      // Tell people this is a practice or special event.
      if (widget.game.type == EventType.Practice) {
        body.add(
          ListTile(
            leading: const Icon(Icons.train),
            title: Text(Messages.of(context).trainingtype),
          ),
        );
      } else if (widget.game.type == EventType.Event) {
        body.add(
          ListTile(
            leading: const Icon(Icons.plus_one),
            title: Text(Messages.of(context).eventtype),
          ),
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: body,
    );
  }
}
