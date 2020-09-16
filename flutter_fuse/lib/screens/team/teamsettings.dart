import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/teams/teamsettings.dart';

class TeamSettingsScreen extends StatelessWidget {
  TeamSettingsScreen(this.teamUid);

  final String teamUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleTeamProvider(
          teamUid: teamUid,
          builder: (BuildContext context, SingleTeamBloc bloc) => BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SingleTeamState teamState) => Text(
              Messages.of(context).titlewith(teamState.team.name),
            ),
          ),
        ),
      ),
      body: TeamSettings(teamUid),
    );
  }
}
