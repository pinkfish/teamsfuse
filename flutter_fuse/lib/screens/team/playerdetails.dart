import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'dart:async';

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
  final RoleInTeam initialRole;

  _RoleInTeamAlertDialog(this.initialRole);

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

    List<DropdownMenuItem<RoleInTeam>> widgets = [];
    RoleInTeam.values.forEach((RoleInTeam role) {
      widgets.add(
        new DropdownMenuItem(
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
          return role;
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
      child: new _RoleInTeamAlertDialog(_player.role),
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
      child: new AlertDialog(
        title: new Text(mess.deleteplayer),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(mess.confirmremovefromteam(_player.displayName)),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              // Do the delete.
              Navigator.of(context).pop(true);
            },
          ),
          new FlatButton(
            child:
                new Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
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
      print('got player ${player.toJSON()}');
      setState(() {
        _playerDetails = player;
      });
    });
  }

  ImageProvider _playerImage() {
    ImageProvider logo;
    if (_player.photoUrl != null && _player.photoUrl.isNotEmpty) {
      logo = new NetworkImage(_player.photoUrl);
    } else {
      logo = const AssetImage("assets/images/defaultavatar2.png");
    }
    return logo;
  }

  Widget _buildPlayerDetails() {
    List<Widget> ret = new List<Widget>();
    final Size screenSize = MediaQuery.of(context).size;
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);

    double width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    double height = screenSize.height / 4 + 20;

    ret.add(
      new CircleAvatar(
        child: new Image(
          image: _playerImage(),
          width: width,
          height: height,
        ),
        radius: (width > height) ? width / 2 : height / 2,
      ),
    );

    ret.add(new ListTile(
      leading: const Icon(CommunityIcons.bookopen),
      title: new Text(messages.roleingame(_player.role)),
    ));

    bool loading = false;

    if (_playerDetails != null && _playerDetails.users != null) {
      _playerDetails.users.forEach((String key, PlayerUser player) {
        if (player.profile != null) {
          if (player.profile.phoneNumber != null &&
              player.profile.phoneNumber.isNotEmpty) {
            ret.add(new ListTile(
              leading: const Icon(Icons.phone),
              title: new Text(
                messages.displaynamerelationship(
                    player.profile.displayName, player.relationship),
              ),
              subtitle: new Text(player.profile.phoneNumber),
            ));
          } else {
            ret.add(new ListTile(
              leading: const Icon(Icons.email),
              title: new Text(player.profile.displayName),
              subtitle: new Text(messages.sendmessage),
            ));
          }
        } else {
          loading = true;
        }
      });
    } else {
      ret.add(new ListTile(
        leading: const Icon(Icons.phone),
        title: new Text(_player.displayName),
      ));
      loading = true;
    }
    if (loading) {
      ret.add(new Text(messages.loading));
      ret.add(new CircularProgressIndicator());
    }

    // Find which seasons they are in.
    _team.seasons.forEach((String key, Season season) {
      if (season.players.any(
          (SeasonPlayer player) => player.playerUid == _player.playerUid)) {
        ret.add(
          new ListTile(
            leading: const Icon(CommunityIcons.tshirtcrew),
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

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(messages.title),
      ),
      body: new SingleChildScrollView(child: _buildPlayerDetails()),
    );
  }
}
