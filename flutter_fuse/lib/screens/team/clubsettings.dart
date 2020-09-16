import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/teams/clubsettings.dart';

class ClubSettingsScreen extends StatelessWidget {
  ClubSettingsScreen(this.teamUid);

  final String teamUid;

  @override
  Widget build(BuildContext context) {
    TeamBloc teams = BlocProvider.of<TeamBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Messages.of(context).titlewith(teams.state.getTeam(teamUid).name),
        ),
      ),
      body: ClubSettings(teamUid),
    );
  }
}
