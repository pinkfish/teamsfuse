import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';

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

  TeamScreenState(this.teamuid) {
    team = UserDatabaseData.instance.teams[teamuid];
    if (team != null) {
      team.thisTeamStream.listen((data) {
        setState(() {

        });
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (team == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.edit),
                tooltip: Messages.of(context).editteam,
                onPressed: () { Navigator.popAndPushNamed(context, "TeamEdit/" + teamuid); })
          ],
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
    );
  }
}