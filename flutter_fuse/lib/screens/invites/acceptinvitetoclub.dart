import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'dialog/deleteinvite.dart';

// Shows the current invites pending for this user.
class AcceptInviteToClubScreen extends StatefulWidget {
  final String _inviteUid;

  AcceptInviteToClubScreen(this._inviteUid);

  @override
  _AcceptInviteToClubScreenState createState() {
    return new _AcceptInviteToClubScreenState();
  }
}

class _AcceptInviteToClubScreenState extends State<AcceptInviteToClubScreen> {
  InviteToClub _invite;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _invite = new InviteToClub(clubName: '');
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
                    onPressed: () => showDeleteInvite(context, _invite),
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
