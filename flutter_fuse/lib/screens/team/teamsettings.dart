import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/teams/teamsettings.dart';
import 'package:fusemodel/blocs.dart';

class TeamSettingsScreen extends StatelessWidget {
  TeamSettingsScreen(this.teamUid);

  final String teamUid;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
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
      body: new TeamSettings(teamUid),
    );
  }
}
