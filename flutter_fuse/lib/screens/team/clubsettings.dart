import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/clubsettings.dart';
import 'package:fusemodel/blocs.dart';

class ClubSettingsScreen extends StatelessWidget {
  ClubSettingsScreen(this.teamUid);

  final String teamUid;

  @override
  Widget build(BuildContext context) {
    TeamBloc teams = BlocProvider.of<TeamBloc>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context)
              .titlewith(teams.currentState.getTeam(teamUid).name),
        ),
      ),
      body: new ClubSettings(teamUid),
    );
  }
}
