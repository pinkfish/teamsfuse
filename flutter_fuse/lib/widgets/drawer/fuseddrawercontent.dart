import 'package:flutter/material.dart';
import 'package:fusemodel/firestore.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/teams/teamtile.dart';

import 'fuseddrawerheader.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:fluro/fluro.dart';

class FusedDrawerContent extends StatelessWidget {
  Widget _buildTeamSection(BuildContext context) {
    List<Widget> data = <Widget>[];
    // If we are specifically in a club, list that here.
    for (Club club in UserDatabaseData.instance.clubs.values) {
      if (club.isMember()) {
        data.add(
          new ListTile(
            leading: const Icon(CommunityIcons.cardsClub),
            title: new RichText(
              text: new TextSpan(
                text: club.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
                children: [
                  new TextSpan(
                      text: club.isAdmin()
                          ? "\n" + Messages.of(context).administrator
                          : "",
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 10.0,
                            color: Theme.of(context).primaryColorDark,
                          )),
                ],
              ),
            ),
            subtitle: new StreamBuilder<Iterable<Team>>(
                stream: club.teamStream,
                builder:
                    (BuildContext context, AsyncSnapshot<Iterable<Team>> snap) {
                  if (snap.hasData) {
                    return new Text(
                      Messages.of(context).teamnumbers(snap.data.length),
                    );
                  }
                  if (club.cachedTeams != null) {
                    return new Text(
                      Messages.of(context).teamnumbers(club.cachedTeams.length),
                    );
                  }
                  return new Text(Messages.of(context).loading);
                }),
            onTap: () {
              AppRouter.instance.navigateTo(context, "Club/" + club.uid,
                  transition: TransitionType.inFromRight);
            },
          ),
        );
      }
    }
    UserDatabaseData.instance.teams.forEach((String uid, Team team) {
      data.add(
        new TeamTile(team),
      );
    });
    data.add(
      new ListTile(
        leading: const Icon(Icons.add),
        title: new Text(
          Messages.of(context).addteam,
          style: Theme.of(context).textTheme.button,
        ),
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
      new ListTile(leading: const Icon(Icons.people_outline),
      title: new Text(Messages.of(context).players),
      onTap: () {
        Navigator.popAndPushNamed(context, "/Players");
      },),
      new ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: new Text(Messages.of(context).signout),
        onTap: () {
          UserDatabaseData.instance.userAuth.signOut();
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
