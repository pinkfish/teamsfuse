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
  GlobalKey<FormState> _formKey;

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
        _invite = inv;
        _invite.playerName.forEach((String str) {
          _checked.add(str);
          _data[str] = str;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _savePressed() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Invite inv = new Invite.copy(_invite);
      inv.playerName.clear();
      _checked.forEach((String name) {
        inv.playerName.add(_data[name]);
      });
      UserDatabaseData.instance.addInvite(inv);
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    List<Widget> players = new List<Widget>();
    ThemeData theme = Theme.of(context);
    _invite.playerName.forEach((String name) {
      players.add(
        new Card(
          child: new ListTile(
            leading: new Checkbox(
              value: _checked.contains(name),
              onChanged: (bool value) {
                print("${value}");
                setState(() {
                  if (value) {
                    _checked.add(name);
                  } else {
                    _checked.remove(name);
                  }
                });
              },
            ),
            title: new TextFormField(
              decoration: new InputDecoration(
                  labelText: messages.playername,
                  hintText: messages.playernamehint),
              initialValue: name,
              onSaved: (String newName) {
                _data[name] = newName;
              },
            ),
          ),
        ),
      );
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[
          new FlatButton(
              onPressed: () {
                this._savePressed(context);
              },
              child: new Text(Messages.of(context).savebuttontext,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white))),
        ],
      ),
      body: new SingleChildScrollView(
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
    );
  }
}
