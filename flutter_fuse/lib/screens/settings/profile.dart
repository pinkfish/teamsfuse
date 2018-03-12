import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() {
    return new ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  StreamSubscription streamListen;
  StreamSubscription playersListen;
  UserData user;
  Player me;

  ProfileScreenState() {
    UserAuth.instance.currentUser().then((UserData data) {
      setState(() {
        user = data;
      });
    });
    streamListen = UserAuth.instance.onAuthChanged().listen((UserData data) {
      setState(() {
        this.user = data;
      });
    });
    playersListen =
        UserDatabaseData.instance.playerStream.listen((UpdateReason update) {
      playersUpdate();
    });
    playersUpdate();
  }

  void playersUpdate() {
    UserDatabaseData.instance.players.forEach((String key, Player player) {
      if (player.users[user.uid].relationship == Relationship.Me) {
        me = player;
      }
    });
  }

  void dispose() {
    super.dispose();
    streamListen.cancel();
    playersListen.cancel();
  }

  List<Widget> _buildPlayerData() {
    final Size screenSize = MediaQuery.of(context).size;
    List<Widget> ret = new List<Widget>();
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

     ret.add(new Center(
      child: new PlayerImage(
        me != null ? me.uid : null,
        width: (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        height: screenSize.height / 4 + 20,
      ),
    ));
    if (user != null) {
      ret.add(new Text(user.displayName, style: theme.textTheme.headline));
      ret.add(new Text(user.email));
      ret.add(new Divider());
      ret.add(new Text(messages.players,
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor)));
      if (UserDatabaseData.instance.players.length > 0) {
        List<Widget> teamNames = new List<Widget>();
        // We have some extra players!
        UserDatabaseData.instance.players.forEach((String key, Player player) {
          // List the teams they are in.
          UserDatabaseData.instance.teams.forEach((String key, Team team) {
            team.seasons.forEach((String key, Season season) {
              int index = season.players.indexWhere((SeasonPlayer sp) {
                return sp.playerUid == player.uid;
              });
              if (index != -1) {
                teamNames.add(new ListTile(
                    leading: const Icon(Icons.people),
                    title: new Text(team.name),
                    subtitle: new Text(
                        messages.roleingame(season.players[index].role))));
              }
            });
          });
          Widget leading;
          Completer<String> photourl = new Completer<String>();
          photourl.complete(player.photoUrl);
          if (player.photoUrl != null) {
            leading = new CachedNetworkImage(imageFuture: photourl.future );
          } else {
            leading = const Image(
                image: const AssetImage("assets/images/defaultavatar2.png"));
          }
          ret.add(new Card(
              child: new Column(
                  children: <Widget>[
                        new ListTile(
                            leading: leading,
                            trailing: const Icon(Icons.edit),
                            title: new Text(player.name)),
                      ] +
                      teamNames)));
        });
      }
    }
    return ret;
  }

  void _editProfile() {
    // Open up the edit profile dialog.
    Navigator.pushNamed(context, "EditProfile");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[
          new FlatButton(
              onPressed: this._editProfile,
              child: new Text(Messages.of(context).editbuttontext,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildPlayerData()),
    );
  }
}
