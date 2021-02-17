import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/teams/teamsettings.dart';

///
/// Ability to edit the settings for the team.
///
class TeamSettingsScreen extends StatelessWidget {
  /// Constructor.
  TeamSettingsScreen(this.teamUid);

  /// The teamUid to edit the team for.
  final String teamUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleTeamProvider(
          teamUid: teamUid,
          builder: (context, bloc) => BlocBuilder(
            cubit: bloc,
            builder: (context, teamState) => Text(
              Messages.of(context).titleWith(teamState.team.name),
            ),
          ),
        ),
      ),
      body: TeamSettings(teamUid),
    );
  }
}
