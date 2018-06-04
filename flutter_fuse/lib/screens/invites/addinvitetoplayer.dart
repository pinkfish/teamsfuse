import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

// Shows the current invites pending for this user.
class AddInviteToPlayerScreen extends StatefulWidget {
  final String _playerUid;

  AddInviteToPlayerScreen(this._playerUid);

  @override
  AddInviteToPlayerScreenState createState() {
    return new AddInviteToPlayerScreenState();
  }
}

class AddInviteToPlayerScreenState extends State<AddInviteToPlayerScreen> {
  InviteToPlayer _invite;
  Player _player;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static const String NEW = 'new';

  @override
  void initState() {
    super.initState();
    _player = UserDatabaseData.instance.players[widget._playerUid];
    // Default to empty.
    _invite = new InviteToPlayer();
    _invite.playerName = _player.name;
    _invite.email = '';
    _invite.playerUid = widget._playerUid;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      UserDatabaseData.instance.players[_invite.playerUid]
          .inviteUser(email: _invite.email);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.followplayer(_player.name)),
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
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: messages.email,
                    hintText: messages.playeremailHint,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  initialValue: _invite.email,
                  onSaved: (String newName) {
                    _invite.email = newName.toLowerCase();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
