import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'dialog/deleteinvite.dart';

// Shows the current invites pending for this user.
class AcceptInviteToTeamScreen extends StatefulWidget {
  final String _inviteUid;

  AcceptInviteToTeamScreen(this._inviteUid);

  @override
  AcceptInviteToTeamScreenState createState() {
    return new AcceptInviteToTeamScreenState();
  }
}

class AcceptInviteToTeamScreenState extends State<AcceptInviteToTeamScreen> {
  InviteToTeam _invite;
  Set<String> _checked;
  Map<String, String> _data;
  Map<String, String> _original = <String, String>{};
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Map<String, String> _current = <String, String>{};
  Map<String, Relationship> _relationship = <String, Relationship>{};
  Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new InviteToTeam(teamName: '', seasonName: '');
    _invite.playerName = <String>[];
    _checked = new Set<String>();
    _data = <String, String>{};
    if (UserDatabaseData.instance.invites.containsKey(widget._inviteUid)) {
      _invite =
          UserDatabaseData.instance.invites[widget._inviteUid] as InviteToTeam;
      for (String str in _invite.playerName) {
        _checked.add(str);
        _current[str] = 'new';
        _data[str] = str;
        _original[str] = str;
      }
    } else {
      // Get out of here.
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onChangedPlayer(String name, String uid) {
    setState(() {
      if (uid.compareTo('new') == 0) {
        _current[name] = 'new';
        _data[name] = _original[name];
        if (_relationship[name] == Relationship.Me) {
          _relationship[name] = Relationship.Friend;
        }
      } else {
        UserDatabaseData data = UserDatabaseData.instance;
        _current[name] = uid;
        _data[name] = data.players[uid].name;
        _relationship[name] =
            data.players[uid].users[data.userUid].relationship;
      }
    });
  }

  Widget _showPlayerDropdown(String name) {
    List<DropdownMenuItem<String>> dropdowns = <DropdownMenuItem<String>>[];

    String found;
    String lowerName = name.toLowerCase().trim();
    UserDatabaseData.instance.players.forEach((String uid, Player play) {
      if (play.name.toLowerCase().trim().compareTo(lowerName) == 0) {
        found = uid;
      }
      dropdowns.add(
        new DropdownMenuItem<String>(
            child: new Text(play.name), value: play.uid),
      );
    });
    dropdowns.add(
      new DropdownMenuItem<String>(
          child: new Text(Messages.of(context).createnew), value: newInvite),
    );
    if (found == null) {
      found = newInvite;
    }
    if (!_current.containsKey(name)) {
      _current[name] = found;
      if (UserDatabaseData.instance.players.containsKey(found)) {
        UserDatabaseData data = UserDatabaseData.instance;
        _relationship[name] =
            data.players[found].users[data.userUid].relationship;
      } else {
        _relationship[name] = Relationship.Friend;
      }
    }
    return new Container(
        child: new DropdownButton<String>(
      items: dropdowns,
      onChanged: (String val) {
        _onChangedPlayer(name, val);
      },
      value: _current[name],
    ));
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      InviteToTeam inv = new InviteToTeam.copy(_invite);
      inv.playerName.clear();
      await Future.forEach(_checked, (String name) async {
        String uid;
        if (_current[name].compareTo(newInvite) == 0) {
          uid = await UserDatabaseData.instance
              .addPlayer(_data[name], _relationship[name]);
        } else {
          uid = _current[name];
        }
        await UserDatabaseData.instance
            .acceptInvite(inv, playerUid: uid, name: _data[name]);
      });
      await inv.firestoreDelete();
      Navigator.pop(context);
    }
  }

  Widget _buildRelationshopDropDown(String name, bool disabled) {
    List<DropdownMenuItem<Relationship>> dropdowns =
        <DropdownMenuItem<Relationship>>[];
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    Relationship.values.forEach((Relationship rel) {
      if (rel != Relationship.Me || disabled) {
        dropdowns.add(
          new DropdownMenuItem<Relationship>(
              child: new Text(messages.relationships(rel)), value: rel),
        );
      }
    });
    TextStyle textStyle = theme.textTheme.subhead;
    if (disabled) {
      textStyle = textStyle.copyWith(
        color: theme.disabledColor,
      );
    }
    print("${_relationship[name]} $_relationship");
    return new DropdownButton<Relationship>(
      items: dropdowns,
      style: textStyle,
      onChanged: disabled
          ? null
          : (Relationship val) {
              _relationship[name] = val;
            },
      value: _relationship[name],
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    List<Widget> players = <Widget>[];
    ThemeData theme = Theme.of(context);
    _invite.playerName.forEach(
      (String name) {
        if (!_controllers.containsKey(name)) {
          _controllers[name] = new TextEditingController();
        }

        players.add(
          new ListTile(
            leading: new Checkbox(
              value: _checked.contains(name),
              onChanged: (bool value) {
                setState(
                  () {
                    if (value) {
                      _checked.add(name);
                    } else {
                      _checked.remove(name);
                    }
                  },
                );
              },
            ),
            title: _showPlayerDropdown(name),
            subtitle: _current[name].compareTo(newInvite) == 0
                ? new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildRelationshopDropDown(name, false),
                      new TextFormField(
                        controller: _controllers[name],
                        decoration: new InputDecoration(
                          labelText: messages.newplayername,
                          hintText: messages.newplayernamehint,
                        ),
                        initialValue: name,
                        onSaved: (String newName) {
                          _data[name] = newName;
                        },
                      ),
                      new ByUserNameComponent(userId: _invite.sentByUid),
                    ],
                  )
                : new FocusScope(
                    node: new FocusScopeNode(),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildRelationshopDropDown(name, true),
                        new TextFormField(
                          controller: _controllers[name],
                          style: theme.textTheme.subhead.copyWith(
                            color: theme.disabledColor,
                          ),
                          decoration: new InputDecoration(
                            labelText: messages.newplayername,
                            hintText: messages.newplayernamehint,
                          ),
                          initialValue: name,
                          onSaved: (String newName) {
                            _data[name] = newName;
                          },
                        ),
                        new ByUserNameComponent(userId: _invite.sentByUid),
                      ],
                    ),
                  ),
          ),
        );
      },
    );

    players.add(
      new Row(
        children: <Widget>[
          new RaisedButton(
            onPressed: _savePressed,
            child: new Text(messages.addinvite),
            color: theme.accentColor,
            textColor: Colors.white,
          ),
          new FlatButton(
            onPressed: () => showDeleteInvite(context, _invite),
            child: new Text(messages.deleteinvite),
          ),
        ],
      ),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _savePressed();
            },
            child: new Text(
              Messages.of(context).savebuttontext,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                    new ListTile(
                      leading: const Icon(CommunityIcons.tshirtCrew),
                      title: new Text(_invite.teamName),
                      subtitle: new Text(_invite.seasonName),
                    )
                  ] +
                  players,
            ),
          ),
        ),
      ),
    );
  }
}
