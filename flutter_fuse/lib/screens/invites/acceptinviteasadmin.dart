import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

// Shows the current invites pending for this user.
class AcceptInviteAsAdminScreen extends StatefulWidget {
  AcceptInviteAsAdminScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteAsAdminScreenState createState() {
    return new _AcceptInviteAsAdminScreenState();
  }
}

class _AcceptInviteAsAdminScreenState extends State<AcceptInviteAsAdminScreen> {
  InviteAsAdmin _invite;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new InviteAsAdmin(teamName: '');
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
                    onPressed: () => showDeleteInvite(context, _invite),
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
