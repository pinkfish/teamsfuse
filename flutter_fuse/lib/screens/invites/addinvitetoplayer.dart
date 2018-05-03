import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/relationshipformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';

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
  Relationship _relationship = Relationship.Friend;
  Map<String, TextEditingController> _controllers =
      new Map<String, TextEditingController>();
  bool _checked;

  static const String NEW = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new InviteToPlayer();
    _invite.playerName = '';
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
      InviteToPlayer inv = new InviteToPlayer.copy(_invite);
      UserDatabaseData.instance.players[_invite.playerUid].inviteUser(email: _invite.email);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    ThemeData theme = Theme.of(context);
    return new Scaffold(
      key: _scaffoldKey,
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
            child: new Column(children: <Widget>[
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
              new RelationshipFormField(
                initialValue: Relationship.Friend,
                onSaved: (Relationship rel) {
                  _relationship = rel;
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
