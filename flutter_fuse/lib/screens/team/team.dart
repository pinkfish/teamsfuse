import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'dart:async';

class TeamScreen extends StatefulWidget {
  String teamuid;

  TeamScreen(this.teamuid);

  @override
  TeamScreenState createState() {
    return new TeamScreenState(this.teamuid);
  }
}

class TeamScreenState extends State<TeamScreen> {
  Team team;
  String teamuid;

  StreamSubscription<UpdateReason> teamUpdate;

  TeamScreenState(this.teamuid) {
    team = UserDatabaseData.instance.teams[teamuid];
    if (team != null) {
      teamUpdate = team.thisTeamStream.listen((data) {
        setState(() {
        });
      });
    }
  }

  @override
  void dispose() {
    teamUpdate.cancel();
    teamUpdate = null;
  }

  Widget _buildSeasons(BuildContext context) {
    List<Widget> ret = new List<Widget>();
    
    team.seasons.forEach((key, season) {
      Iterable<Game> games = season.getGames();
      List<Widget> newData = new List<Widget>();

      games.forEach((game) {
        newData.add(new GameCard(game));
      });
      if (games.length == 0) {
        newData.add(new Text(Messages.of(context).nogames));
      }

      ret.add(new ExpansionTile(
        title: new Text(
              season.name + " W:" +
                  season.record.win.toString() + " L:" +
                  season.record.loss.toString() + " T:" +
                  season.record.tie.toString()),
        children: newData,
        initiallyExpanded: season.uid == team.currentSeason,
      ));
    });
    return new Column(
      children: ret,
    );
  }

  void _onFABPressed(BuildContext context) {
    Navigator.popAndPushNamed(context, "TeamEdit/" + teamuid);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (team == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
        ),
        body: new Column(
          children: <Widget>[
            new Center(
                child: new Image(
                  image: new ExactAssetImage("assets/images/abstractsport.png"),
                  width: (screenSize.width < 500)
                      ? 120.0
                      : (screenSize.width / 4) + 12.0,
                  height: screenSize.height / 4 + 20,
                )
            ),
            new ListTile(
                title: new Text(Messages.of(context).unknown)
            ),
            _buildSeasons(context)
          ],
        ),
      );
    }



    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new Column(
        children: <Widget>[
          new Center(
            child: new Image(
              image: new ExactAssetImage("assets/images/abstractsport.png"),
              width: (screenSize.width < 500)
                  ? 120.0
                  : (screenSize.width / 4) + 12.0,
              height: screenSize.height / 4 + 20,
            )
          ),
          new ListTile(
            title: new Text(team.name),
            subtitle: new Text(team.sport.toString() + "(" + team.league + ") " + team.gender.toString())
          ),
          _buildSeasons(context)
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () { _onFABPressed(context); },
        tooltip: Messages.of(context).teamedithint,
        child: new Icon(Icons.edit),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}