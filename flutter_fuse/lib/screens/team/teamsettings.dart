import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamsettings.dart';
import 'package:fusemodel/fusemodel.dart';

class TeamSettingsScreen extends StatelessWidget {
  TeamSettingsScreen(this.teamUid);

  final String teamUid;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context)
              .titlewith(UserDatabaseData.instance.teams[teamUid].name),
        ),
      ),
      body: new TeamSettings(teamUid),
    );
  }
}
