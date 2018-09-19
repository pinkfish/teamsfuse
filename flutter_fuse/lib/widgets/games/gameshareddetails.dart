import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_fuse/services/map_view/marker.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/util/leagueteamimage.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';

import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

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
  void initState() {
    super.initState();
  }

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
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        print("$widget");
        //return new EditResultDialog(widget.game);
        return FlatButton(
          child: Text("Adding results"),
          onPressed: () => Navigator.pop(context, false),
        );
      },
    );
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
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: LeagueTeamImage(
                      leagueOrTeamUid:
                          widget.game.officalResults.homeTeamLeagueUid,
                      width: 50.0,
                      height: 50.0,
                    ),
                  ),
                  LeagueOrTournamentTeamName(
                      widget.game.officalResults.homeTeamLeagueUid,
                      style: theme.textTheme.subhead)
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 50.0,
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
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: LeagueTeamImage(
                      leagueOrTeamUid:
                          widget.game.officalResults.awayTeamLeagueUid,
                      width: 50.0,
                      height: 50.0,
                    ),
                  ),
                  LeagueOrTournamentTeamName(
                    widget.game.officalResults.awayTeamLeagueUid,
                    style: theme.textTheme.subhead,
                    textAlign: TextAlign.end,
                  )
                ],
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
        TextStyle resultStyle;

        // Started.
        switch (widget.game.officalResults.result) {
          case OfficalResult.NotStarted:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officalResults);
            resultStyle = theme.textTheme.subhead;
            break;
          case OfficalResult.InProgress:
            if (widget.game.officalResults.result != OfficalResult.NotStarted) {
              title = Messages.of(context)
                  .gameofficalinprogress(widget.game.officalResults);
              resultStyle = theme.textTheme.subhead;
            } else {
              title = Messages.of(context).resultunknown;
              resultStyle = theme.textTheme.subhead;
            }
            break;
          case OfficalResult.HomeTeamWon:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officalResults);
            resultStyle = theme.textTheme.subhead;
            break;
          case OfficalResult.AwayTeamWon:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officalResults);
            resultStyle = theme.textTheme.subhead;
            break;
          case OfficalResult.Tie:
            title = Messages.of(context)
                .gameofficalinprogress(widget.game.officalResults);
            resultStyle = theme.textTheme.subhead;
            break;
        }
        body.add(
          new ListTile(
            onTap: _editResult,
            leading: LeagueImage(
              leagueOrTournamentUid: widget.game.leagueUid,
              width: 50.0,
              height: 50.0,
            ),
            title: LeagueOrTournamentName(widget.game.leagueUid),
            subtitle: new Text(title),
          ),
        );
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
