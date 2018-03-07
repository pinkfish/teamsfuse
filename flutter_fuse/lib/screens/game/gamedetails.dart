import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:map_view/map_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:uri/uri.dart';
import 'dart:async';

class GameDetailsScreen extends StatefulWidget {
  GameDetailsScreen(this.gameUid);

  final String gameUid;

  @override
  GameDetailsScreenState createState() {
    return new GameDetailsScreenState(gameUid);
  }
}

class GameDetailsScreenState extends State<GameDetailsScreen> {
  final String gameUid;
  Game game;
  StreamSubscription<UpdateReason> teamUpdate;
  ScrollController _scrollController = new ScrollController();

  GameDetailsScreenState(this.gameUid) {
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

  @override
  Widget build(BuildContext context) {
    print('lat: ${game.place.latitude} long: ${game.place.longitude}');
    Location loc = new Location(game.place.latitude, game.place.longitude);
    Marker marker = new Marker(game.place.placeId, game.place.address,
        game.place.latitude, game.place.longitude);
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
    }
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent opponent = team.opponents[game.opponentUid];
    Season season = team.seasons[game.seasonUid];
    String seasonStr;
    if (season != null) {
      seasonStr = season.name;
    } else {
      seasonStr = Messages.of(context).unknown;
    }

    ThemeData theme = Theme.of(context);

    Widget loadingWidget = new Column(
      children: <Widget>[
        new Text(Messages.of(context).loading),
        new CircularProgressIndicator()
      ],
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
        ),
        bottomNavigationBar: new BottomNavigationBar(items: [
          new BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            title: new Text("Main details"),
          ),
          new BottomNavigationBarItem(
              icon: const Icon(Icons.people), title: new Text("Availability"))
        ]),
        body: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child:
              new Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                  Widget>[
            new Container(
                height: 250.0,
                child: new Stack(
                  children: <Widget>[
                    new Center(
                        child: new Container(
                            padding: const EdgeInsets.all(20.0),
                            child: loadingWidget)),
                    new InkWell(
                      onTap: openNavigation,
                      child:
                          new Center(child: new Image.network(uri.toString())),
                    )
                  ],
                )),
            new ListTile(
              leading: new TeamImage(game.teamUid, width: 50.0, height: 50.0),
              title: new Text(team.name, style: theme.textTheme.title),
              subtitle: new Text('arrive at ' + arriveAttimeStr,
                  style: theme.textTheme.subhead),
            ),
            new ListTile(
              leading: new Icon(Icons.map),
              title: new Text(
                  dateStr + " " + timeStr + " arrive at " + arriveAttimeStr,
                  style: theme.textTheme.subhead
                      .copyWith(color: theme.accentColor)),
              subtitle: new Text(game.place.address),
            ),
            new ListTile(
              leading: new Icon(Icons.gamepad),
              title: new Text(opponent.name),
              subtitle:
                  new Text(Messages.of(context).winrecord(opponent.record)),
            ),
            new ListTile(
              leading: const Icon(Icons.home),
              title: game.homegame ? new Text('Home') : new Text('Away'),
            ),
            new ListTile(
              leading: const Icon(Icons.check),
              title: new Text(game.uniform == null ? 'fluff' : game.uniform),
            ),
            new ListTile(
                leading: const Icon(Icons.note),
                title: new Text(game.notes == null ? 'No notes' : game.notes)),
            new ExpansionTile(
              onExpansionChanged: this._opponentExpansionChanged,
              title: new Text(opponent.name + " games"),
              initiallyExpanded: false,
              children: <Widget>[],
            )
          ]),
        ));
  }
}
