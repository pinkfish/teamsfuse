import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'dart:async';

import 'fuseddrawerheader.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:fluro/fluro.dart';

class FusedDrawerContent extends StatelessWidget {
  Widget _buildTeamSection(BuildContext context) {
    List<Widget> data = new List<Widget>();
    UserDatabaseData.instance.teams.forEach((uid, team) {
      data.add(new ListTile(
          leading: const Icon(Icons.group),
          title: new Text(team.name),
          onTap: () {
            AppRouter.instance.navigateTo(context, "Team/" + team.uid,
                transition: TransitionType.inFromRight);
          }));
    });
    data.add(new ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Add Team'),
        onTap: () {}));
    return new Column(children: data);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      new FusedDrawerHeader(),
      new StreamBuilder(
          stream: UserDatabaseData.instance.teamStream,
          builder:
              (BuildContext context, AsyncSnapshot<UpdateReason> snapshot) {
            return this._buildTeamSection(context);
          }),
      new Divider(),
      new ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: const Text('Signout'),
        onTap: () {
          UserAuth.instance.signOut();
          Navigator.of(context).pushNamed("/Home");
        },
      ),
      new ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.popAndPushNamed(context, "/Settings");
        },
      ),
      new ListTile(
        leading: const Icon(Icons.help),
        title: const Text('About'),
        onTap: () {
          Navigator.popAndPushNamed(context, "/About");
        },
      ),
    ];
    return new ListView(children: children);
  }
}
