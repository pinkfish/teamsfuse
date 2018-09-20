import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'dialog/deleteinvite.dart';

class AcceptInviteToLeagueScreen extends StatefulWidget {
  final String _inviteUid;

  AcceptInviteToLeagueScreen(this._inviteUid);

  @override
  _AcceptInviteToLeagueScreenState createState() {
    return new _AcceptInviteToLeagueScreenState();
  }
}

class _AcceptInviteToLeagueScreenState
    extends State<AcceptInviteToLeagueScreen> {
  InviteToLeagueAsAdmin _invite;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
    if (UserDatabaseData.instance.invites.containsKey(widget._inviteUid)) {
      _invite = UserDatabaseData.instance.invites[widget._inviteUid]
          as InviteToLeagueAsAdmin;
    } else {
      // Get out of here.
      _invite = new InviteToLeagueAsAdmin(leagueUid: '');

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
        title: new Text(Messages.of(context).league),
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new ListTile(
                leading: LeagueImage(
                  leagueOrTournamentUid: _invite.leagueUid,
                  width: 50.0,
                  height: 50.0,
                ),
                title: new Text(_invite.leagueName),
                subtitle: new ByUserNameComponent(userId: _invite.sentByUid),
              ),
              new ButtonBar(
                children: <Widget>[
                  new RaisedButton(
                    onPressed: _savePressed,
                    child: new Text(messages.joinleague),
                    color: theme.accentColor,
                    textColor: Colors.white,
                  ),
                  new FlatButton(
                    onPressed: () => Navigator.pushNamed(
                        context, "/League/Main/" + _invite.leagueUid),
                    child: Text(messages.openbutton),
                  ),
                  new FlatButton(
                    onPressed: () => showDeleteInvite(context, _invite),
                    child: new Icon(Icons.delete),
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
