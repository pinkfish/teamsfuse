import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import '../screens/publicclubhome.dart';
import '../services/messagespublic.dart';

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
  PublicClubTeams(this.clubBloc,
      {this.onTap, this.selected, this.smallDisplay = false});

  /// The club to show the teams for.
  final SingleClubBloc clubBloc;

  /// The team to tap on.
  final TeamCallback onTap;

  /// Which team is selected.
  final Team selected;

  /// If this is small display,
  final bool smallDisplay;

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

    for (final team in myTeam) {
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
    final teamWidgets = <Widget>[];
    if (singleClubState is SingleClubLoaded) {
      if (!singleClubState.loadedTeams) {
        teamWidgets.add(Text(
          Messages.of(context).loading,
        ));
      } else {
        if (singleClubState.teams.isNotEmpty) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          Messages.of(context).teams,
          style: Theme.of(context)
              .textTheme
              .headline4
              .copyWith(color: Colors.green),
        ),
        SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: teamWidgets,
            ),
          ),
        ),
        smallDisplay
            ? ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context,
                        '/Club/'
                        '${PublicClubTab.club.name}'
                        '/${singleClubState.club.uid}'),
                    child: Text(
                      MessagesPublic.of(context).aboutButton,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context,
                        '/Club/'
                        '${PublicClubTab.coaches.name}'
                        '/${singleClubState.club.uid}'),
                    child: Text(
                      MessagesPublic.of(context).coachesButton,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context,
                        '/Club/'
                        '${PublicClubTab.news.name}'
                        '/${singleClubState.club.uid}'),
                    child: Text(
                      MessagesPublic.of(context).newsButton,
                    ),
                  ),
                ],
              )
            : SizedBox(height: 0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: clubBloc,
      builder: (context, state) {
        if (state is SingleClubLoaded && !state.loadedTeams) {
          clubBloc.add(SingleClubLoadTeams(publicLoad: true));
        }
        return _buildTeams(context, state);
      },
    );
  }
}
