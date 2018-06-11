import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamsettings.dart';

class TeamSettingsScreen extends StatelessWidget {

  final String teamUid;
  TeamSettingsScreen(this.teamUid);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new TeamSettings(teamUid),
    );
  }
}