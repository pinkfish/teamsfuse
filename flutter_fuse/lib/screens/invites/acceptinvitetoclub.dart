import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';

// Shows the current invites pending for this user.
class AcceptInviteToClubScreen extends StatefulWidget {
  final String _inviteUid;

  AcceptInviteToClubScreen(this._inviteUid);

  @override
  AcceptInviteToClubScreenState createState() {
    return new AcceptInviteToClubScreenState();
  }
}

class AcceptInviteToClubScreenState extends State<AcceptInviteToClubScreen> {
  InviteToClub _invite;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new InviteToClub();
    _invite.clubName = '';
    if (UserDatabaseData.instance.invites.containsKey(widget._inviteUid)) {
      _invite =
      UserDatabaseData.instance.invites[widget._inviteUid] as InviteToClub;
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
    _invite.acceptInvite();
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
                leading: const Icon(CommunityIcons.houzz),
                title: new Text(_invite.clubName),
                subtitle: new ByUserNameComponent(userId: _invite.sentByUid),
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
