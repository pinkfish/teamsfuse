import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/invites/deleteinvitedialog.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerDetailsScreen extends StatefulWidget {
  PlayerDetailsScreen(this.teamUid, this.seasonUid, this.playerUid);
  final String teamUid;
  final String seasonUid;
  final String playerUid;

  @override
  PlayerDetailsScreenState createState() {
    return new PlayerDetailsScreenState();
  }
}

class _RoleInTeamAlertDialog extends StatefulWidget {
  _RoleInTeamAlertDialog(this.initialRole);

  final RoleInTeam initialRole;

  @override
  _RoleInTeamAlertDialogState createState() {
    return new _RoleInTeamAlertDialogState();
  }
}

class _RoleInTeamAlertDialogState extends State<_RoleInTeamAlertDialog> {
  RoleInTeam _myRole;

  @override
  void initState() {
    super.initState();
    _myRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    List<DropdownMenuItem<RoleInTeam>> widgets =
        <DropdownMenuItem<RoleInTeam>>[];
    RoleInTeam.values.forEach((RoleInTeam role) {
      widgets.add(
        new DropdownMenuItem<RoleInTeam>(
          child: new Text(
            messages.roleingame(role),
          ),
          value: role,
        ),
      );
    });

    return new AlertDialog(
      title: new Text(messages.roleselect),
      content: new DropdownButton<RoleInTeam>(
        items: widgets,
        value: _myRole,
        onChanged: (RoleInTeam role) {
          print('changed $role');
          setState(() {
            _myRole = role;
          });
        },
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () {
            // Do the delete.
            Navigator.of(context).pop(_myRole);
          },
        ),
        new FlatButton(
          child: new Text(MaterialLocalizations.of(context).cancelButtonLabel),
          onPressed: () {
            // Do the delete.
            Navigator.of(context).pop(null);
          },
        ),
      ],
    );
  }
}

class PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  SeasonPlayer _player;
  Team _team;
  Season _season;
  Player _playerDetails;

  StreamSubscription<UpdateReason> _stream;

  @override
  void initState() {
    print('initState');
    super.initState();
    // Lookup the player.
    _team = UserDatabaseData.instance.teams[widget.teamUid];
    _season = _team.seasons[widget.seasonUid];
    List<SeasonPlayer> seasonPlayers = _season.players;
    _player = seasonPlayers.firstWhere((SeasonPlayer player) {
      return player.playerUid == widget.playerUid;
    });
    _stream = UserDatabaseData.instance.playerStream.listen(_playerUpdated);
    // Get the actual player too, so we can show who else is associated
    // with them.
    _playerUpdated(UpdateReason.Update);
  }

  @override
  void dispose() {
    super.dispose();
    if (_stream != null) {
      _stream.cancel();
      _stream = null;
    }
  }

  void _changeRole() async {
    RoleInTeam role = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new _RoleInTeamAlertDialog(_player.role);
      },
    );
    if (role != null) {
      _season.updateRoleInTeam(_player, role);
      _player.role = role;
    }
  }

  void _removeFromTeam() async {
    Messages mess = Messages.of(context);

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
                    new FutureBuilder<Player>(
                        future: UserDatabaseData.instance
                            .getPlayer(_player.playerUid),
                        builder: (BuildContext context,
                            AsyncSnapshot<Player> player) {
                          if (player.hasData) {
                            return new Text(
                                mess.confirmremovefromteam(player.data.name));
                          }
                          return new Text(
                              mess.confirmremovefromteam(mess.loading));
                        }),
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
      _season.removePlayer(_player);
      Navigator.pop(context);
    }
  }

  void _playerUpdated(UpdateReason reason) {
    _team = UserDatabaseData.instance.teams[widget.teamUid];
    _season = _team.seasons[widget.seasonUid];
    List<SeasonPlayer> seasonPlayers = _season.players;
    _player = seasonPlayers.firstWhere((SeasonPlayer player) {
      return player.playerUid == widget.playerUid;
    });
    // Lookup the player and then lookup the profiles.
    UserDatabaseData.instance
        .getPlayer(_player.playerUid, withProfile: true)
        .then((Player player) {
      setState(() {
        _playerDetails = player;
      });
    });
  }

  void _deleteInvite(BuildContext context, InviteToPlayer invite) {
    deleteInviteDialog(context, invite);
  }

  Widget _buildPlayerDetails() {
    List<Widget> ret = <Widget>[];
    final Size screenSize = MediaQuery.of(context).size;
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);

    double width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    double height = screenSize.height / 4 + 20;

    ret.add(
      new PlayerImage(
        playerUid: _player.playerUid,
        radius: width > height ? height / 2 : width / 2,
      ),
    );

    ret.add(
      new ListTile(
        leading: const Icon(CommunityIcons.bookOpenVariant),
        title: new Text(
          messages.roleingame(_player.role),
        ),
      ),
    );

    if (_playerDetails != null && _playerDetails.users != null) {
      _playerDetails.users.forEach((String key, PlayerUser player) {
        ret.add(new FutureBuilder<FusedUserProfile>(
            future: player.getProfile(),
            builder: (BuildContext context,
                AsyncSnapshot<FusedUserProfile> profile) {
              if (!profile.hasData) {
                return new Text(messages.loading);
              }

              if (profile.data.phoneNumber != null &&
                  profile.data.phoneNumber.isNotEmpty) {
                return new ListTile(
                  leading: const Icon(Icons.phone),
                  title: new Text(
                    messages.displaynamerelationship(
                        profile.data.displayName, player.relationship),
                  ),
                  subtitle: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                          "${profile.data.phoneNumber}\n${profile.data.email}"),
                      new Row(
                        children: <Widget>[
                          new IconButton(
                            icon: const Icon(Icons.sms),
                            color: Theme.of(context).primaryColorDark,
                            onPressed: () =>
                                launch("sms:" + profile.data.phoneNumber),
                          ),
                          new IconButton(
                            icon: const Icon(Icons.email),
                            color: Theme.of(context).primaryColorDark,
                            onPressed: () =>
                                launch("mailto:" + profile.data.email),
                          ),
                          new IconButton(
                            icon: const Icon(Icons.message),
                            color: Theme.of(context).primaryColorDark,
                            onPressed: () => Navigator.pushNamed(
                                context,
                                "/AddMessagePlayer/" +
                                    widget.teamUid +
                                    "/" +
                                    widget.seasonUid +
                                    "/" +
                                    widget.playerUid),
                          )
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return new ListTile(
                  leading: const Icon(Icons.email),
                  title: new Text(profile.data.displayName),
                  subtitle: new Text(messages.sendmessage),
                );
              }
            }));
      });
      ret.add(
        new StreamBuilder<List<InviteToPlayer>>(
          stream: _playerDetails.inviteStream,
          builder:
              (BuildContext context, AsyncSnapshot<List<InviteToPlayer>> snap) {
            List<InviteToPlayer> invites = _playerDetails.cachedInvites;
            if (invites == null || invites.length == 0) {
              if (!snap.hasData || snap.data.length == 0) {
                return new SizedBox(height: 0.0);
              }
            }

            return new Column(
              children: invites.map((InviteToPlayer invite) {
                return new ListTile(
                  leading: const Icon(Icons.person_add),
                  title: new Text(Messages.of(context).invitedemail(invite)),
                  trailing: new IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteInvite(context, invite),
                  ),
                );
              }).toList(),
            );
          },
        ),
      );
    }

    // Find which seasons they are in.
    _team.seasons.forEach((String key, Season season) {
      if (season.players.any(
          (SeasonPlayer player) => player.playerUid == _player.playerUid)) {
        ret.add(
          new ListTile(
            leading: const Icon(CommunityIcons.tshirtCrew),
            title: new Text(season.name),
          ),
        );
      }
    });

    if (_team.isAdmin()) {
      ret.add(
        new Row(
          children: <Widget>[
            new FlatButton(
              onPressed: _changeRole,
              child: new Text(messages.changerole),
              textColor: theme.accentColor,
            ),
            new FlatButton(
              onPressed: _removeFromTeam,
              child: new Text(messages.deleteplayer),
              textColor: theme.accentColor,
            ),
          ],
        ),
      );
    }

    return new Column(
      children: ret,
    );
  }

  void _onInvite(BuildContext context) {
    Navigator.pushNamed(context, "AddInviteToPlayer/" + widget.playerUid);
  }

  void _editPlayer(BuildContext context) {
    Navigator.pushNamed(context, "EditPlayer/" + _playerDetails.uid);
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
    List<Widget> actions = <Widget>[];
    if (UserDatabaseData.instance.teams.containsKey(widget.teamUid)) {
      if (UserDatabaseData.instance.teams[widget.teamUid].isAdmin()) {
        actions.add(
          new FlatButton(
            onPressed: () {
              _onInvite(context);
            },
            child: new Text(
              messages.addinvite,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        );
      }
    }

    FloatingActionButton fab;
    if (_playerDetails != null &&
        _playerDetails.users.containsKey(UserDatabaseData.instance.userUid)) {
      // I am a member of this player, can edit them!
      fab = new FloatingActionButton(
        onPressed: () => _editPlayer(context),
        child: const Icon(Icons.edit),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new PlayerName(playerUid: _player.playerUid),
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: _buildPlayerDetails(),
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
