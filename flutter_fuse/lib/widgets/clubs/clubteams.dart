import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamtile.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubTeams extends StatelessWidget {
  ClubTeams(this.clubBloc) {
    clubBloc.add(SingleClubLoadTeams());
  }

  final SingleClubBloc clubBloc;

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
        new TeamTile(team.uid),
      );
    }
    return teamWidgets;
  }

  Widget _buildTeams(BuildContext context, SingleClubState singleClubState) {
    List<Widget> teamWidgets = <Widget>[];
    if (singleClubState is SingleClubLoaded) {
      if (singleClubState.teams.length != 0) {
        teamWidgets = _teamTiles(context, singleClubState.teams);
      } else {
        teamWidgets.add(new Text(Messages.of(context).loading));
      }
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
    return BlocBuilder(
      cubit: clubBloc,
      builder: (BuildContext context, SingleClubState state) {
        return _buildTeams(context, state);
      },
    );
  }
}
