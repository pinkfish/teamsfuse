import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'dart:async';

class TeamDetails extends StatefulWidget {
  String teamuid;

  TeamDetails(this.teamuid);

  @override
  TeamDetailsState createState() {
    return new TeamDetailsState(this.teamuid);
  }
}

class TeamDetailsState extends State<TeamDetails> {
  Team team;
  String teamuid;
  int _tabIndex = 0;

  StreamSubscription<UpdateReason> teamUpdate;

  TeamDetailsState(this.teamuid) {
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
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (team == null) {
      return new Column(
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
        );
    }



    return  new Column(
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
      );
  }
}