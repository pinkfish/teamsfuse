import 'package:fusemodel/fusemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamtile.dart';

class ClubTeams extends StatelessWidget {
  final Club club;

  ClubTeams(this.club);

  Widget _buildTeams(
      BuildContext context, AsyncSnapshot<Iterable<Team>> teams) {
    List<Widget> teamWidgets = <Widget>[];

    if (teams.hasData) {
      List<Team> myTeam = teams.data.toList();
      myTeam.sort((Team a, Team b) => a.name.compareTo(b.name));

      for (Team team in myTeam) {
        teamWidgets.add(
          new TeamTile(team),
        );
      }
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
        child:
            new StreamBuilder(stream: club.teamStream, builder: _buildTeams));
  }
}
