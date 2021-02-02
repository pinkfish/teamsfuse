import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/teams/clubsettings.dart';

///
/// Show the settings for the club.
class ClubSettingsScreen extends StatelessWidget {
  /// Constructor.
  ClubSettingsScreen(this.teamUid);

  /// The teamUid to show the club settings for.
  final String teamUid;

  @override
  Widget build(BuildContext context) {
    var teams = BlocProvider.of<TeamBloc>(context);
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
