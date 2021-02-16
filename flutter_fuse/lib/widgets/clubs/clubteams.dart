import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleclubprovider.dart';
import '../teams/teamtile.dart';

///
/// Callback for if a specific team is tapped.
///
typedef TeamCallback = void Function(Team team);

///
/// Shows the teams inside the club.
///
class ClubTeams extends StatelessWidget {
  /// Constructor.
  ClubTeams(this.clubUid, {this.onlyPublic = false, this.onTap, this.selected});

  /// The club to show the teams for.
  final String clubUid;

  /// Only show public clubs.
  final bool onlyPublic;

  /// The method to call when a team is tapped on.
  final TeamCallback onTap;

  /// Which team is currently selected.
  final Team selected;

  List<Widget> _teamTiles(BuildContext context, Iterable<Team> teams) {
    var teamWidgets = <Widget>[];
    var myTeam = teams.toList();
    myTeam.sort((a, b) => a.name.compareTo(b.name));

    if (myTeam.isEmpty) {
      // Put in a no teams marker...
      teamWidgets.add(
        SizedBox(
          height: 40.0,
        ),
      );
      teamWidgets.add(
        Center(
          child: Text(Messages.of(context).noTeams,
              style: Theme.of(context).textTheme.headline6),
        ),
      );
    }

    for (var team in myTeam) {
      teamWidgets.add(
        TeamTile(
          team.uid,
          onTap: onTap != null ? () => onTap(team) : null,
          selected: selected != null && selected.uid == team.uid,
        ),
      );
    }
    return teamWidgets;
  }

  Widget _buildTeams(BuildContext context, SingleClubState singleClubState) {
    var teamWidgets = <Widget>[];
    if (singleClubState is SingleClubUninitialized) {
      teamWidgets.add(Text(Messages.of(context).loading));
    } else if (singleClubState is SingleClubLoaded) {
      if (singleClubState.teams.isNotEmpty) {
        teamWidgets = _teamTiles(context, singleClubState.teams);
      } else {
        teamWidgets.add(
          Text(
            Messages.of(context).noTeams,
            style: Theme.of(context).textTheme.headline4,
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: teamWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, singleClubBloc) => BlocBuilder(
        cubit: singleClubBloc,
        builder: (context, state) {
          if (!state.loadedTeams) {
            singleClubBloc.add(SingleClubLoadTeams(publicLoad: onlyPublic));
          }
          return _buildTeams(context, state);
        },
      ),
    );
  }
}
