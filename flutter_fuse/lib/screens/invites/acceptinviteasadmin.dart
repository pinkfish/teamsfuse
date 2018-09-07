import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(10.0),
                child: new Text(
                  Messages.of(context).acceptinviteasadmin,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              new ListTile(
                leading: const Icon(CommunityIcons.tshirtCrew),
                title: new Text(_invite.teamName),
                subtitle: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(Messages.of(context).administrator),
                    new ByUserNameComponent(userId: _invite.sentByUid),
                  ],
                ),
              ),
              new SizedBox(height: 75.0),
              new Divider(),
              new Row(
                children: <Widget>[
                  new SizedBox(width: 5.0),
                  new RaisedButton(
                    onPressed: _savePressed,
                    child: new Text(messages.addadmin),
                    color: theme.accentColor,
                    textColor: Colors.white,
                  ),
                  new FlatButton(
                    onPressed: _deletePressed,
                    child: new Text(messages.deleteinvitebutton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
