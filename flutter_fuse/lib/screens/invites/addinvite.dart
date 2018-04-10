import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

// Shows the current invites pending for this user.
class AddInviteScreen extends StatefulWidget {
  final String _inviteUid;

  AddInviteScreen(this._inviteUid);

  @override
  AddInviteScreenState createState() {
    return new AddInviteScreenState();
  }
}

class AddInviteScreenState extends State<AddInviteScreen> {
  Invite _invite;
  Set<String> _checked;
  Map<String, String> _data;
  Map<String, String> _original = new Map<String, String>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Map<String, String> _current = new Map<String, String>();
  Map<String, Relationship> _relationship = new Map<String, Relationship>();
  Map<String, TextEditingController> _controllers =
      new Map<String, TextEditingController>();

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new Invite();
    _invite.playerName = [];
    _invite.teamName = '';
    _invite.seasonName = '';
    _checked = new Set<String>();
    _data = new Map<String, String>();
    UserDatabaseData.instance.getInvite(widget._inviteUid).then((Invite inv) {
      setState(() {
        if (inv != null) {
          _invite = inv;
          _invite.playerName.forEach((String str) {
            _checked.add(str);
            _current[str] = 'new';
            _data[str] = str;
            _original[str] = str;
          });
        } else {
          // Get out of here.
          Navigator.pop(context);
        }
      });
    });
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
    List<DropdownMenuItem<String>> dropdowns =
        new List<DropdownMenuItem<String>>();

    String found;
    String lowerName = name.toLowerCase().trim();
    UserDatabaseData.instance.players.forEach((String uid, Player play) {
      if (play.name.toLowerCase().trim().compareTo(lowerName) == 0) {
        found = uid;
      }
      dropdowns.add(
        new DropdownMenuItem(child: new Text(play.name), value: play.uid),
      );
    });
    dropdowns.add(
      new DropdownMenuItem(
          child: new Text(Messages.of(context).createnew), value: 'new'),
    );
    if (found == null) {
      found = 'new';
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
      Invite inv = new Invite.copy(_invite);
      inv.playerName.clear();
      await Future.forEach(_checked, (String name) async {
        String uid;
        if (_current[name].compareTo('new') == 0) {
          uid = await UserDatabaseData.instance
              .addPlayer(_data[name], _relationship[name]);
        } else {
          uid = _current[name];
        }
        await UserDatabaseData.instance.acceptInvite(inv, uid, _data[name]);
      });
      await inv.firestoreDelete();
      Navigator.pop(context);
    }
  }

  void _deletePressed() async {
    Messages mess = Messages.of(context);

    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: new AlertDialog(
        title: new Text(mess.deleteinvite),
        content: new Scrollbar(
          child: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(mess.confirmdelete(_invite)),
              ],
            ),
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
      await _invite.firestoreDelete();
      Navigator.pop(context);
    }
  }

  Widget _buildRelationshopDropDown(String name, bool disabled) {
    List<DropdownMenuItem<Relationship>> dropdowns =
        new List<DropdownMenuItem<Relationship>>();
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    Relationship.values.forEach((Relationship rel) {
      if (rel != Relationship.Me || disabled) {
        dropdowns.add(
          new DropdownMenuItem(
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

    List<Widget> players = new List<Widget>();
    ThemeData theme = Theme.of(context);
    _invite.playerName.forEach((String name) {
      if (!_controllers.containsKey(name)) {
        _controllers[name] = new TextEditingController();
      }

      players.add(
        new Card(
          child: new ListTile(
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
            subtitle: _current[name].compareTo('new') == 0
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
                      )
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
                      ],
                    ),
                  ),
          ),
        ),
      );
    });

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
            onPressed: _deletePressed,
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
              this._savePressed();
            },
            child: new Text(
              Messages.of(context).savebuttontext,
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
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                    new ListTile(
                      leading: const Icon(CommunityIcons.tshirtcrew),
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
