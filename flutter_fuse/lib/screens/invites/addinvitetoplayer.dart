import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

// Shows the current invites pending for this user.
class AddInviteToPlayerScreen extends StatefulWidget {
  AddInviteToPlayerScreen(this._playerUid);

  final String _playerUid;

  @override
  _AddInviteToPlayerScreenState createState() {
    return new _AddInviteToPlayerScreenState();
  }
}

class _AddInviteToPlayerScreenState extends State<AddInviteToPlayerScreen> {
  InviteToPlayer _invite;
  Player _player;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static const String newAddInvite = 'new';

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    super.initState();
    _player = UserDatabaseData.instance.players[widget._playerUid];
    // Default to empty.
    _invite = new InviteToPlayer(
        playerName: _player.name, playerUid: widget._playerUid, email: '');
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      UserDatabaseData.instance.players[_invite.playerUid]
          .inviteUser(email: _invite.email)
          .then((void e) {
        Navigator.pop(context);
      }).catchError((dynamic e) {
        print(e);
        showInSnackBar("Error " + e.toString());
      });
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
