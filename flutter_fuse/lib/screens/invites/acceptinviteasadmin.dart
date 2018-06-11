import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

// Shows the current invites pending for this user.
class AcceptInviteAsAdminScreen extends StatefulWidget {
  final String _inviteUid;

  AcceptInviteAsAdminScreen(this._inviteUid);

  @override
  AcceptInviteAsAdminScreenState createState() {
    return new AcceptInviteAsAdminScreenState();
  }
}

class AcceptInviteAsAdminScreenState extends State<AcceptInviteAsAdminScreen> {
  InviteAsAdmin _invite;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new InviteAsAdmin();
    _invite.teamName = '';
    if (UserDatabaseData.instance.invites.containsKey(widget._inviteUid)) {
      _invite =
          UserDatabaseData.instance.invites[widget._inviteUid] as InviteAsAdmin;
    } else {
      // Get out of here.
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _savePressed() async {
    _invite.acceptInvite(UserDatabaseData.instance.mePlayer.uid);
    await _invite.firestoreDelete();
    Navigator.pop(context);
  }

  void _deletePressed() async {
    Messages mess = Messages.of(context);

    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
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
      await _invite.firestoreDelete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new ListTile(
                leading: const Icon(CommunityIcons.tshirtcrew),
                title: new Text(_invite.teamName),
              ),
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
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(),
        child: const Icon(Icons.check),
      ),
    );
  }
}
