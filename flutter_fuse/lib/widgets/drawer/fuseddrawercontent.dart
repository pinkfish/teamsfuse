import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

import 'fuseddrawerheader.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:fluro/fluro.dart';

class FusedDrawerContent extends StatelessWidget {
  Widget _buildTeamSection(BuildContext context) {
    List<Widget> data = <Widget>[];
    UserDatabaseData.instance.teams.forEach((String uid, Team team) {
      WinRecord record;
      String seasonName = "";
      if (team.seasons.containsKey(team.currentSeason)) {
        record = team.seasons[team.currentSeason].record;
        seasonName = team.seasons[team.currentSeason].name;
      }
      data.add(
        new ListTile(
          leading: const Icon(Icons.group),
          title: new RichText(
            text: new TextSpan(
              text: team.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
              children: <TextSpan>[
                new TextSpan(text: "  "),
                new TextSpan(
                    text: seasonName,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(fontStyle: FontStyle.italic, fontSize: 15.0)),
              ],
            ),
          ),
          isThreeLine: false,
          dense: false,
          subtitle: new Text(record != null ? Messages.of(context).winrecord(record) : ""),
          onTap: () {
            AppRouter.instance.navigateTo(context, "Team/" + team.uid,
                transition: TransitionType.inFromRight);
          },
        ),
      );
    });
    data.add(
      new ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Add Team'),
        onTap: () => Navigator.pushNamed(context, "AddTeam"),
      ),
    );
    return new Column(children: data);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      new FusedDrawerHeader(),
      new StreamBuilder<UpdateReason>(
        stream: UserDatabaseData.instance.teamStream,
        builder: (BuildContext context, AsyncSnapshot<UpdateReason> snapshot) {
          return _buildTeamSection(context);
        },
      ),
      new Divider(),
      new ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: new Text(Messages.of(context).signout),
        onTap: () {
          UserAuth.instance.signOut();
          //Navigator.of(context).pushNamed("/Home");
        },
      ),
      new ListTile(
        leading: const Icon(Icons.settings),
        title: new Text(Messages.of(context).settings),
        onTap: () {
          Navigator.popAndPushNamed(context, "/Settings");
        },
      ),
      new ListTile(
        leading: const Icon(Icons.help),
        title: new Text(Messages.of(context).about),
        onTap: () {
          Navigator.popAndPushNamed(context, "/About");
        },
      ),
    ];
    return new ListView(children: children);
  }
}
