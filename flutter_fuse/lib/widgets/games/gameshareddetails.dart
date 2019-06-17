import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/map_view/marker.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/util/leagueteamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import 'officalresultdialog.dart';

class GameSharedDetails extends StatefulWidget {
  GameSharedDetails(this.game, {this.adding = false});

  final GameSharedData game;
  final bool adding;

  @override
  _GameSharedDetailsState createState() {
    return new _GameSharedDetailsState();
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

  void openNavigation() {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(widget.game.place.address);
    if (widget.game.place.placeId != null) {
      url += "&destination_place_id=" +
          Uri.encodeComponent(widget.game.place.placeId);
    }
    launch(url);
  }

  void _editResult() async {
    // Call up a dialog to edit the result.
    await fullScreenDialog(
      context: context,
      builder: (BuildContext context) {
        return new OfficialResultDialog(widget.game);
      },
    );
  }

  Future<bool> fullScreenDialog({BuildContext context, WidgetBuilder builder}) {
    return Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<bool>(builder: builder, fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    print(
        'lat: ${widget.game.place.latitude} long: ${widget.game.place.longitude} ${widget.game.uid}');
    Marker marker = new Marker(
        widget.game.place.placeId,
        widget.game.place.address,
        widget.game.place.latitude.toDouble(),
        widget.game.place.longitude.toDouble());
    Uri uri = MapData.instance.provider
        .getStaticUriWithMarkers(<Marker>[marker], width: 900, height: 400);
    TimeOfDay day = new TimeOfDay.fromDateTime(widget.game.tzTime);
    TimeOfDay dayEnd = new TimeOfDay.fromDateTime(widget.game.tzEndTime);
    String dateStr =
        MaterialLocalizations.of(context).formatFullDate(widget.game.tzTime);
    String timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeStr =
        MaterialLocalizations.of(context).formatTimeOfDay(dayEnd);
    String tzShortName;
    if (widget.game.timezone != local.name) {
      tzShortName = " (" +
          getLocation(widget.game.timezone)
              .timeZone(widget.game.time.toInt())
              .abbr +
          ")";
    }
    print('${widget.game.timezone} ${widget.game.tzTime}');

    ThemeData theme = Theme.of(context);

    Widget loadingWidget = new Column(
      children: <Widget>[
        new Text(Messages.of(context).loading),
        new CircularProgressIndicator()
      ],
    );

    List<Widget> body = <Widget>[];
    // Map view.
    body.add(
      new Container(
        height: 250.0,
        child: new Stack(
          children: <Widget>[
            new Center(
              child: new CachedNetworkImage(
                placeholder: new Center(
                  child: new Container(
                    padding: const EdgeInsets.all(20.0),
                    child: loadingWidget,
                  ),
                ),
                imageUrl: uri.toString(),
              ),
            ),
            new Positioned(
              right: 20.0,
              bottom: 0.0,
              child: new FloatingActionButton(
                onPressed: openNavigation,
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
    TextStyle homeStyle = Theme.of(context).textTheme.subhead;
    TextStyle awayStyle = Theme.of(context).textTheme.subhead;

    if (widget.game.officialResults.result == OfficialResult.AwayTeamWon) {
      awayStyle =
          awayStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w600);
    }
    if (widget.game.officialResults.result == OfficialResult.HomeTeamWon) {
      homeStyle =
          homeStyle.copyWith(color: Colors.green, fontWeight: FontWeight.w700);
    }
    List<Widget> homeTeamDetails = <Widget>[
      Align(
        alignment: Alignment.topRight,
        child: LeagueTeamImage(
          leagueOrTeamUid: widget.game.officialResults.homeTeamLeagueUid,
          width: 50.0,
          height: 50.0,
        ),
      ),
      LeagueOrTournamentTeamName(
        widget.game.officialResults.homeTeamLeagueUid,
        style: homeStyle,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
      )
    ];

    List<Widget> awayTeamDetails = <Widget>[
      Align(
        alignment: Alignment.topLeft,
        child: LeagueTeamImage(
          leagueOrTeamUid: widget.game.officialResults.awayTeamLeagueUid,
          width: 50.0,
          height: 50.0,
        ),
      ),
      LeagueOrTournamentTeamName(
        widget.game.officialResults.awayTeamLeagueUid,
        style: awayStyle,
        overflow: TextOverflow.ellipsis,
      )
    ];

    if (widget.game.type == EventType.Game &&
        widget.game.officialResults.result != OfficialResult.NotStarted) {
      TextStyle homeStyle =
          Theme.of(context).textTheme.display1.copyWith(fontSize: 25.0);
      TextStyle awayStyle =
          Theme.of(context).textTheme.display1.copyWith(fontSize: 25.0);
      if (widget.game.officialResults.result == OfficialResult.AwayTeamWon) {
        awayStyle = awayStyle.copyWith(color: Colors.green);
      }
      if (widget.game.officialResults.result == OfficialResult.HomeTeamWon) {
        homeStyle = homeStyle.copyWith(color: Colors.green);
      }
      if (widget.game.officialResults.scores
          .containsKey(GamePeriod.regulation)) {
        TextStyle tmpHomeStyle = homeStyle;
        TextStyle tmpAwayStyle = awayStyle;
        if (widget.game.officialResults.scores.length > 1) {
          tmpHomeStyle = homeStyle.copyWith(fontSize: 20.0);
          tmpAwayStyle = awayStyle.copyWith(fontSize: 20.0);
        }
        homeTeamDetails.add(Text(
          widget.game.officialResults.scores[GamePeriod.regulation].score.ptsFor
              .toString(),
          style: tmpHomeStyle,
          textAlign: TextAlign.end,
        ));
        awayTeamDetails.add(Text(
          widget.game.officialResults.scores[GamePeriod.regulation].score
              .ptsAgainst
              .toString(),
          style: tmpAwayStyle,
          textAlign: TextAlign.start,
        ));
      }
      if (widget.game.officialResults.scores.containsKey(GamePeriod.overtime)) {
        homeTeamDetails.add(Text(
          "OT ${widget.game.officialResults.scores[GamePeriod.overtime].score.ptsFor}",
          style: homeStyle,
          textAlign: TextAlign.end,
        ));
        awayTeamDetails.add(Text(
          "OT ${widget.game.officialResults.scores[GamePeriod.overtime].score.ptsAgainst}",
          style: awayStyle,
          textAlign: TextAlign.start,
        ));
      }
      if (widget.game.officialResults.scores.containsKey(GamePeriod.penalty)) {
        homeTeamDetails.add(Text(
          "PT ${widget.game.officialResults.scores[GamePeriod.penalty].score.ptsFor}",
          style: homeStyle,
          textAlign: TextAlign.end,
        ));
        awayTeamDetails.add(Text(
          "PT ${widget.game.officialResults.scores[GamePeriod.penalty].score.ptsAgainst}",
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
                style: Theme.of(context).textTheme.title,
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
    body.add(
      new ListTile(
        leading: new Icon(Icons.directions),
        title: new Text(
          dateStr +
              " " +
              timeStr +
              (widget.game.endTime == widget.game.time
                  ? ''
                  : " - " + endTimeStr + (tzShortName ?? "")),
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor),
        ),
        subtitle: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(widget.game.place.name ?? ''),
            new Text(widget.game.place.address ?? Messages.of(context).unknown),
          ],
        ),
      ),
    );

    // Results.
    if (widget.game.type == EventType.Game) {
      if (widget.adding) {
        body.add(
          new ListTile(
            leading: new Icon(CommunityIcons.bookOpenVariant),
            title: new Text(Messages.of(context).gametype),
          ),
        );
      } else {
        String title;

        // Started.
        switch (widget.game.officialResults.result) {
          case OfficialResult.NotStarted:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResults.result);
            break;
          case OfficialResult.InProgress:
            if (widget.game.officialResults.result !=
                OfficialResult.NotStarted) {
              title = Messages.of(context)
                  .gameofficalinprogress(widget.game.officialResults.result);
            } else {
              title = Messages.of(context).resultunknown;
            }
            break;
          case OfficialResult.HomeTeamWon:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResults.result);
            break;
          case OfficialResult.AwayTeamWon:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResults.result);
            break;
          case OfficialResult.Tie:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officialResults.result);
            break;
        }
        body.add(
          new ListTile(
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
            subtitle: new Text(
              title,
              textAlign: TextAlign.start,
            ),
          ),
        );
        LeagueOrTournament leagueOrTournament;
        LeagueOrTournamentBloc leagueOrTournamentBloc =
            BlocProvider.of<LeagueOrTournamentBloc>(context);
        if (leagueOrTournamentBloc.currentState.leagueOrTournaments
            .containsValue(widget.game.leagueUid)) {
          leagueOrTournament = leagueOrTournamentBloc
              .currentState.leagueOrTournaments[widget.game.leagueUid];
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
          new ListTile(
            leading: const Icon(Icons.train),
            title: new Text(Messages.of(context).trainingtype),
          ),
        );
      } else if (widget.game.type == EventType.Event) {
        body.add(
          new ListTile(
            leading: const Icon(Icons.plus_one),
            title: new Text(Messages.of(context).eventtype),
          ),
        );
      }
    }

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: body,
    );
  }
}
