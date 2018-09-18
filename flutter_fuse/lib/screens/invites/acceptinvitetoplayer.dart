import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/relationshipformfield.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'dialog/deleteinvite.dart';

// Shows the current invites pending for this user.
class AcceptInviteToPlayerScreen extends StatefulWidget {
  final String _inviteUid;

  AcceptInviteToPlayerScreen(this._inviteUid);

  @override
  AcceptInviteToPlayerScreenState createState() {
    return new AcceptInviteToPlayerScreenState();
  }
}

class AcceptInviteToPlayerScreenState
    extends State<AcceptInviteToPlayerScreen> {
  InviteToPlayer _invite;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Relationship _relationship = Relationship.Friend;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    _invite =
        UserDatabaseData.instance.invites[widget._inviteUid] as InviteToPlayer;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      UserDatabaseData.instance
          .acceptInvite(_invite, relationship: _relationship);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.followplayer(_invite.playerName)),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _savePressed();
            },
            child: new Text(
              messages.savebuttontext,
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
          child: new DropdownButtonHideUnderline(
            child: new Form(
              key: _formKey,
              child: new Column(
                children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.all(20.0),
                    child: new Text(
                      messages.playerinvitedesc(_invite.playerName),
                    ),
                  ),
                  new RelationshipFormField(
                    initialValue: Relationship.Friend,
                    decoration: new InputDecoration(
                      labelText: messages.relationshipselect,
                      icon: const Icon(Icons.person),
                    ),
                    onSaved: (Relationship rel) {
                      _relationship = rel;
                    },
                  ),
                  new Container(
                    padding: new EdgeInsets.only(top: 20.0),
                    child: new ByUserNameComponent(userId: _invite.sentByUid),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(top: 20.0),
                    child: ButtonBar(
                      children: <Widget>[
                        new RaisedButton(
                          onPressed: _savePressed,
                          child: new Text(messages.addplayer),
                        ),
                        new FlatButton(
                          onPressed: () => showDeleteInvite(context, _invite),
                          child: new Text(messages.deleteinvite),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
