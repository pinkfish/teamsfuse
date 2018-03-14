import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:map_view/map_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/games/editresultdialog.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';

import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

class GameDetails extends StatefulWidget {
  GameDetails(this.gameUid);

  final String gameUid;

  @override
  GameDetailsState createState() {
    return new GameDetailsState(gameUid);
  }
}

class GameDetailsState extends State<GameDetails> {
  final String gameUid;
  Game game;
  StreamSubscription<UpdateReason> teamUpdate;

  GameDetailsState(this.gameUid) {
    game = UserDatabaseData.instance.games[gameUid];
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    if (team != null) {
      teamUpdate = team.thisTeamStream.listen((data) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    teamUpdate.cancel();
    teamUpdate = null;
  }

  void openNavigation() {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(game.place.address);
    if (game.place.placeId != null) {
      url +=
          "&destionation_place_id=" + Uri.encodeComponent(game.place.placeId);
    }
    launch(url);
  }

  void _opponentExpansionChanged(bool expansion) {
    // Setup a call for extra stuff.
  }

  void _editResult() async {
    // Call up a dialog to edit the result.
    await showDialog(context: context, child: new EditResultDialog(this.game));
  }

  @override
  Widget build(BuildContext context) {
    print('lat: ${game.place.latitude} long: ${game.place.longitude}');
    Location loc = new Location(
        game.place.latitude.toDouble(), game.place.longitude.toDouble());
    Marker marker = new Marker(game.place.placeId, game.place.address,
        game.place.latitude.toDouble(), game.place.longitude.toDouble());
    var uri = MapData.instance.provider
        .getStaticUriWithMarkers([marker], width: 900, height: 400);
    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    TimeOfDay dayArrive = new TimeOfDay.fromDateTime(game.tzArriveTime);
    String dateStr =
        MaterialLocalizations.of(context).formatMediumDate(game.tzTime);
    String timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String arriveAttimeStr;
    if (dayArrive.minute == day.minute && dayArrive.hour == day.hour) {
      arriveAttimeStr =
          MaterialLocalizations.of(context).formatTimeOfDay(dayArrive);
    } else {
      arriveAttimeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    }
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent opponent = team.opponents[game.opponentUid];

    ThemeData theme = Theme.of(context);

    Widget loadingWidget = new Column(
      children: <Widget>[
        new Text(Messages.of(context).loading),
        new CircularProgressIndicator()
      ],
    );

    List<Widget> body = new List<Widget>();
    // Map view.
    body.add(
      new Container(
          height: 250.0,
          child: new InkWell(
            onTap: openNavigation,
            child: new Center(
                child: new CachedNetworkImage(
                    placeholder: new Center(
                        child: new Container(
                            padding: const EdgeInsets.all(20.0),
                            child: loadingWidget)),
                    imageNow: uri.toString())),
          )),
    );

    // Team details
    body.add(new ListTile(
      leading: new TeamImage(game.teamUid, width: 50.0, height: 50.0),
      title: new Text(team.name, style: theme.textTheme.title),
      subtitle: arriveAttimeStr != null
          ? new Text('arrive at ' + arriveAttimeStr,
              style: theme.textTheme.subhead)
          : null,
      trailing: game.homegame ? const Icon(Icons.home) : null,
    ));

    // Map details
    body.add(new ListTile(
      leading: new Icon(Icons.directions),
      title: new Text(dateStr + " " + timeStr,
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor)),
      subtitle: new Text(game.place.address),
    ));

    // Results.
    String title;
    TextStyle resultStyle;
    switch (game.result.result) {
      case GameResult.Unknown:
        title = Messages.of(context).resultunknown;
        resultStyle = theme.textTheme.subhead;
        break;
      case GameResult.Loss:
        title = Messages.of(context).resultloss(game.result);
        resultStyle = theme.textTheme.subhead.copyWith(color: theme.errorColor);
        break;
      case GameResult.Win:
        title = Messages.of(context).resultwin(game.result);
        resultStyle =
            theme.textTheme.subhead.copyWith(color: theme.accentColor);
        break;
      case GameResult.Tie:
        title = Messages.of(context).resulttie(game.result);
        resultStyle = theme.textTheme.subhead;
        break;
      case GameResult.InProgress:
        title = Messages.of(context).resultinprogress(game.result);
        resultStyle = theme.textTheme.subhead;
        break;
    }
    body.add(new ListTile(
        onTap: this._editResult,
        leading: new Icon(CommunityIcons.bookopenvariant),
        title: new Text(title, style: resultStyle)));

    // Uniform
    if (game.uniform != null && !game.uniform.isEmpty) {
      body.add(new ListTile(
          leading: const Icon(CommunityIcons.tshirtcrew),
          title: new Text(game.uniform == null ? 'fluff' : game.uniform)));
    }

    // Notes.
    if (game.uniform != null && !game.uniform.isEmpty) {
      body.add(new ListTile(
          leading: const Icon(Icons.note), title: new Text(game.notes)));
    }

    // Opponent last games.
    String seasonName;
    if (team.seasons.containsKey(game.seasonUid)) {
      seasonName = team.seasons[game.seasonUid].name;
    } else {
      seasonName = Messages.of(context).unknown;
    }
    body.add(new ExpansionTile(
      onExpansionChanged: this._opponentExpansionChanged,
      title: new Row(children: <Widget>[
        new Text(Messages.of(context).opponentwinrecord(opponent, game.seasonUid, seasonName))
      ]),
      initiallyExpanded: false,
      leading: const Icon(Icons.people),
      children: <Widget>[],
    ));
    if (team.seasons.length > 1) {
      body.add(new ExpansionTile(title: new Text(Messages.of(context).previousSeasons),
      initiallyExpanded:  false,
      leading: const Icon(Icons.people),
      children: <Widget>[]));
    }

    return new Column(
        mainAxisAlignment: MainAxisAlignment.start, children: body);
  }
}
