import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:flutter_fuse/widgets/invites/deleteinvitedialog.dart';
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

  void initState() {
    super.initState();
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
      if (player.users[UserDatabaseData.instance.userUid].relationship ==
          Relationship.Me) {
        me = player;
      }
    });
  }

  void dispose() {
    super.dispose();
    streamListen.cancel();
    playersListen.cancel();
  }

  void _editPlayer(String uid) {
    Navigator.pushNamed(context, "EditPlayer/" + uid);
  }

  void _deletePlayer(Player player) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog and stuff.
    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(mess.deleteplayer),
            content: new Scrollbar(
              child: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(mess.confirmdeleteplayer(player)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  // Do the delete.
                  Navigator.of(context).pop(true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
    if (result) {
      player.removeFirebaseUser(UserDatabaseData.instance.userUid);
    }
  }

  void _deleteInvite(BuildContext context, InviteToPlayer invite) async {
    await deleteInviteDialog(context, invite);
  }

  void _onAddPlayerInvite(BuildContext context, Player player) {
    Navigator.pushNamed(context, "AddInviteToPlayer/" + player.uid);
  }

  List<Widget> _buildUserList(BuildContext context, Player player) {
    List<Widget> ret = [];
    ret.add(
      new StreamBuilder(
        stream: player.inviteStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<InviteToPlayer>> snap) {
          if (!snap.hasData || snap.data.length == 0) {
            return null;
          }
          return new Card(
            child: new Column(
              children: snap.data.map((InviteToPlayer invite) {
                return new ListTile(
                  leading: const Icon(Icons.message),
                  title: new Text(Messages.of(context).invitedemail(invite)),
                  trailing: new IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => this._deleteInvite(context, invite)),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
    ret.add(
      new ListTile(
        leading: const Icon(Icons.plus_one),
        title: new Text(Messages.of(context).addinvite),
        onTap: () => this._onAddPlayerInvite(context, player),
      ),
    );

    player.users.forEach((String str, PlayerUser user) {
      ret.add(new FutureBuilder(
        future: user.getProfile(),
        builder:
            (BuildContext context, AsyncSnapshot<FusedUserProfile> profile) {
          if (profile.hasData) {
            return new ListTile(
              title: new Text(Messages.of(context).displaynamerelationship(
                  profile.data.displayName, user.relationship)),
              subtitle: new Text(profile.data.email),
            );
          } else {
            return new ListTile(
              title: new Text(Messages.of(context).displaynamerelationship(
                  Messages.of(context).loading, user.relationship)),
            );
          }
        },
      ));
    });
    return ret;
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
      ret.add(
          new Text(user.profile.displayName, style: theme.textTheme.headline));
      ret.add(
        new ListTile(
          leading: const Icon(Icons.email),
          title: new Text(user.email),
        ),
      );
      ret.add(
        new ListTile(
          leading: const Icon(Icons.phone),
          title: new Text(user.profile.phoneNumber),
        ),
      );
      ret.add(new Divider());
      ret.add(new Text(messages.players,
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor)));
      if (UserDatabaseData.instance.players.length > 0) {
        // We have some extra players!
        UserDatabaseData.instance.players.forEach((String key, Player player) {
          List<Widget> teamNames = [];
          // List the teams they are in.
          UserDatabaseData.instance.teams.forEach((String key, Team team) {
            team.seasons.forEach((String key, Season season) {
              int index = season.players.indexWhere((SeasonPlayer sp) {
                return sp.playerUid == player.uid;
              });
              if (index != -1) {
                teamNames.add(
                  new GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, "EditPlayer/" + player.uid),
                    child: new ListTile(
                      leading: const Icon(Icons.people),
                      title: new Text(team.name),
                      subtitle: new Text(
                        messages.roleingame(season.players[index].role),
                      ),
                      trailing: new IconButton(
                        onPressed: () {
                          this._deletePlayer(player);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  ),
                );
              }
            });
          });
          ImageProvider leading;
          if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
            leading = new CachedNetworkImageProvider(urlNow: player.photoUrl);
          } else {
            leading = const AssetImage("assets/images/defaultavatar2.png");
          }
          ret.add(
            new Card(
              child: new Column(
                  children: <Widget>[
                        new ListTile(
                          leading: new CircleAvatar(backgroundImage: leading),
                          trailing: new IconButton(
                            onPressed: () {
                              _editPlayer(player.uid);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          title: new Text(player.name),
                        ),
                        new ExpansionTile(
                          title: new Text(messages
                              .numberofuserforplayer(player.users.length)),
                          initiallyExpanded: false,
                          children: _buildUserList(context, player),
                        )
                      ] +
                      teamNames),
            ),
          );
        });
      }
    }
    return ret;
  }

  void _editProfile() {
    // Open up the edit profile dialog.
    Navigator.pushNamed(context, "EditProfile/" + me.uid);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[
          new FlatButton(
            onPressed: this._editProfile,
            child: new Text(
              Messages.of(context).editbuttontext,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildPlayerData(),
          ),
        ),
      ),
    );
  }
}
