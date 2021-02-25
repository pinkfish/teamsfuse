import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleclubprovider.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import 'publlicteamtile.dart';

///
/// Callback for if a specific team is tapped.
///
typedef TeamCallback = void Function(Team team);

///
/// Shows the teams inside the club puclically.
///
class PublicClubTeams extends StatelessWidget {
  /// Constructor.
  PublicClubTeams(this.club,
      {this.onlyPublic = false, this.onTap, this.selected});

  /// The club to show the teams for.
  final Club club;
  final bool onlyPublic;
  final TeamCallback onTap;
  final Team selected;

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
          child: Text(Messages.of(context).noTeams,
              style: Theme.of(context).textTheme.headline6),
        ),
      );
    }

    for (var team in myTeam) {
      teamWidgets.add(
        SizedBox(
          width: double.infinity,
          child: PublicTeamTile(
            team.uid,
            onTap: onTap != null ? () => onTap(team) : null,
            selected: selected != null && selected.uid == team.uid,
          ),
        ),
      );
    }
    return teamWidgets;
  }

  Widget _buildTeams(BuildContext context, SingleClubState singleClubState) {
    var teamWidgets = <Widget>[];
    teamWidgets.add(SizedBox(height: 10));
    teamWidgets.add(Text(
      club.name,
      style: Theme.of(context).textTheme.headline4,
    ));
    teamWidgets.add(SizedBox(height: 10));
    teamWidgets.add(Text(
      Messages.of(context).teams,
      style:
          Theme.of(context).textTheme.headline6.copyWith(color: Colors.green),
    ));
    teamWidgets.add(SizedBox(height: 10));
    if (singleClubState is SingleClubLoaded) {
      if (!singleClubState.loadedTeams) {
        teamWidgets.add(Text(
          Messages.of(context).loading,
        ));
      } else {
        if (singleClubState.teams.length != 0) {
          teamWidgets.addAll(_teamTiles(context, singleClubState.teams));
        } else {
          teamWidgets.add(
            Text(
              Messages.of(context).noTeams,
              style: Theme.of(context).textTheme.headline4,
            ),
          );
        }
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
      clubUid: club.uid,
      builder: (context, singleClubBloc) => BlocBuilder(
        cubit: singleClubBloc,
        builder: (context, state) {
          if (state is SingleClubLoaded && !state.loadedTeams) {
            singleClubBloc.add(SingleClubLoadTeams(publicLoad: true));
          }
          return _buildTeams(context, state);
        },
      ),
    );
  }
}
