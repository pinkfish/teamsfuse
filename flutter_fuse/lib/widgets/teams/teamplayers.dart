import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'dart:async';

class TeamPlayers extends StatefulWidget {
  final String _teamUid;

  TeamPlayers(this._teamUid);

  @override
  TeamPlayersState createState() {
    return new TeamPlayersState();
  }
}

class TeamPlayersState extends State<TeamPlayers> {
  String _seasonUid;
  Team _team;
  Season _season;
  List<InviteToTeam> _invites;
  StreamSubscription<UpdateReason> _updateStream;
  StreamSubscription<List<InviteToTeam>> _inviteStream;

  TeamPlayersState();

  @override
  void initState() {
    super.initState();
    _team = UserDatabaseData.instance.teams[widget._teamUid];
    updateSeason(_team.currentSeason);
    _updateStream = _team.thisTeamStream.listen((UpdateReason upd) {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    if (_updateStream != null) {
      _updateStream.cancel();
      _updateStream = null;
    }
    if (_inviteStream != null) {
      _inviteStream.cancel();
      _inviteStream = null;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_updateStream != null) {
      _updateStream.cancel();
      _updateStream = null;
    }
    if (_inviteStream != null) {
      _inviteStream.cancel();
      _inviteStream = null;
    }
    super.dispose();
  }

  void updateSeason(String seasonUid) {
    if (_team.seasons.containsKey(seasonUid)) {
      _seasonUid = _team.currentSeason;
      _season = _team.seasons[seasonUid];
      // Look for the invites.
      _inviteStream = _season.inviteStream.listen((List<InviteToTeam> invites) {
        setState(() {
          _invites = invites;
        });
      });
    }
  }

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    if (widget._teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(widget._teamUid)) {
      UserDatabaseData.instance.teams[widget._teamUid].seasons
          .forEach((key, season) {
        ret.add(new DropdownMenuItem(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }

  void _deleteInvite(InviteToTeam invite) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteinvite),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(mess.confirmdelete(invite)),
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
        );
      },
    );
    if (result) {
      invite.firestoreDelete();
    }
  }

  List<Widget> _buildPlayers() {
    List<Widget> ret = new List<Widget>();
    ThemeData theme = Theme.of(context);

    _season.players.forEach((SeasonPlayer player) {
      ret.add(
        new GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context,
                "PlayerDetails/" +
                    _team.uid +
                    "/" +
                    _season.uid +
                    "/" +
                    player.playerUid);
          },
          child: new ListTile(
            leading: new PlayerImage(player.playerUid),
            title: new Text(player.displayName),
            subtitle: new Text(
              Messages.of(context).roleingame(player.role),
            ),
          ),
        ),
      );
    });
    ret.add(
      new ListTile(
        title: new FlatButton(
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pushNamed(
                context, "AddPlayer/" + widget._teamUid + "/" + _seasonUid);
          },
          child: new Text(Messages.of(context).addplayer),
        ),
      ),
    );

    // Put in an expansion bar if there are pending invites.
    if (_invites != null &&
        _invites.length > 0 &&
        _team.isAdmin(UserDatabaseData.instance.players)) {
      List<Widget> kids = new List<Widget>();
      _invites.forEach((InviteToTeam inv) {
        kids.add(
          new ListTile(
            title: new Row(
              children: inv.playerName.map((String name) {
                return new Chip(
                    backgroundColor: Colors.lightBlueAccent,
                    label: new Text(name));
              }).toList(),
            ),
            leading: const Icon(Icons.email),
            subtitle: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5.0),
                new Text(
                  inv.email,
                  style: theme.textTheme.body1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5.0),
                new Text(Messages.of(context).roleingame(inv.role)),
              ],
            ),
            trailing: new IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteInvite(inv);
              },
            ),
          ),
        );
      });
      ret.add(new ExpansionTile(
          title: new Text(Messages.of(context).invitedpeople(_invites.length)),
          children: kids));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messsages = Messages.of(context);

    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new DropdownButton(
              hint: new Text(messsages.seasonselect),
              value: _seasonUid,
              items: _buildItems(context),
              onChanged: (dynamic val) {
                print('changed $val');
                setState(() {
                  _seasonUid = val;
                  _season = _team.seasons[val];
                });
              },
            ),
          ],
        ),
        new Expanded(
          child: new Container(
            constraints: new BoxConstraints(),
            margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            decoration: new BoxDecoration(color: theme.cardColor),
            child: new SingleChildScrollView(
              child: new Column(children: _buildPlayers()),
            ),
          ),
        )
      ],
    );
  }
}
