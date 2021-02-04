import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../teams/teamtile.dart';

///
/// Shows the teams inside the club.
///
class ClubTeams extends StatelessWidget {
  /// Constructor.
  ClubTeams(this.clubBloc) {
    clubBloc.add(SingleClubLoadTeams());
  }

  /// The club to show the teams for.
  final SingleClubBloc clubBloc;

  List<Widget> _teamTiles(BuildContext context, Iterable<Team> teams) {
    var teamWidgets = <Widget>[];
    var myTeam = teams.toList();
    myTeam.sort((a, b) => a.name.compareTo(b.name));

    if (myTeam.length == 0) {
      // Put in a no teams marker...
      teamWidgets.add(
        SizedBox(
          height: 40.0,
        ),
      );
      teamWidgets.add(
        Center(
          child: Text(Messages.of(context).noteams,
              style: Theme.of(context).textTheme.headline6),
        ),
      );
    }

    for (var team in myTeam) {
      teamWidgets.add(
        TeamTile(team.uid),
      );
    }
    return teamWidgets;
  }

  Widget _buildTeams(BuildContext context, SingleClubState singleClubState) {
    var teamWidgets = <Widget>[];
    if (singleClubState is SingleClubLoaded) {
      if (singleClubState.teams.length != 0) {
        teamWidgets = _teamTiles(context, singleClubState.teams);
      } else {
        teamWidgets.add(Text(Messages.of(context).loading));
      }
    }

    return Column(
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
      builder: (context, state) {
        if (state is SingleClubLoaded && !state.loadedTeams) {
          clubBloc.add(SingleClubLoadTeams());
        }
        return _buildTeams(context, state);
      },
    );
  }
}
