import 'package:fusemodel/fusemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamtile.dart';

class ClubTeams extends StatelessWidget {
  final Club club;

  ClubTeams(this.club);

  List<Widget> _teamTiles(BuildContext context, Iterable<Team> teams) {
    List<Widget> teamWidgets = <Widget>[];
    List<Team> myTeam = teams.toList();
    myTeam.sort((Team a, Team b) => a.name.compareTo(b.name));

    if (myTeam.length == 0) {
      // Put in a no teams marker...
      teamWidgets.add(
        new SizedBox(
          height: 40.0,
        ),
      );
      teamWidgets.add(
        new Center(
          child: new Text(Messages.of(context).noteams,
              style: Theme.of(context).textTheme.title),
        ),
      );
    }

    for (Team team in myTeam) {
      teamWidgets.add(
        new TeamTile(team),
      );
    }
    return teamWidgets;
  }

  Widget _buildTeams(
      BuildContext context, AsyncSnapshot<Iterable<Team>> teams) {
    List<Widget> teamWidgets = <Widget>[];

    if (teams.hasData) {
      teamWidgets = _teamTiles(context, teams.data);
    } else if (club.cachedTeams != null) {
      teamWidgets = _teamTiles(context, club.cachedTeams);
    } else {
      teamWidgets.add(new Text(Messages.of(context).loading));
    }

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: teamWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new StreamBuilder<Iterable<Team>>(
        stream: club.teamStream,
        builder: _buildTeams,
      ),
    );
  }
}
