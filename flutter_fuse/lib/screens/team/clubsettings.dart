import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/clubsettings.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubSettingsScreen extends StatelessWidget {
  ClubSettingsScreen(this.teamUid);

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
      body: new ClubSettings(teamUid),
    );
  }
}
