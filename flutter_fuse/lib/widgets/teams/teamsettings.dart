import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'dart:async';

class TeamSettings extends StatefulWidget {
  final String _teamUid;

  TeamSettings(this._teamUid);

  @override
  TeamSettingsState createState() {
    return new TeamSettingsState();
  }
}

class TeamSettingsState extends State<TeamSettings> {
  Team _team;
  StreamSubscription<UpdateReason> _updateStream;
  bool _addAdminDisplayed = false;

  @override
  void initState() {
    super.initState();
    _team = UserDatabaseData.instance.teams[widget._teamUid];
    _updateStream = _team.thisTeamStream.listen((UpdateReason upd) {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _updateStream?.cancel();
    _updateStream = null;
    super.deactivate();
  }

  @override
  void dispose() {
    _updateStream?.cancel();
    _updateStream = null;
    super.dispose();
  }

  void _deleteAdmin(String adminUid, String name) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteadmin),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(name),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (result) {
      _team.deleteAdmin(adminUid);
    }
  }

  void _deleteInvite(InviteAsAdmin adm) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteadmininvite),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(adm.email),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
    if (result) {
      adm.firestoreDelete();
    }
  }

  void _addAdmin() {
    Navigator.pushNamed(context, "TeamAddAdmin/" + _team.uid);
  }

  List<Widget> _buildAdmins(List<Widget> ret) {
    ThemeData theme = Theme.of(context);

    ret.add(new Text("Admins", style: theme.textTheme.title));

    for (String uid in _team.admins) {
      print('$uid');
      ret.add(
        new FutureBuilder<Player>(
          future: UserDatabaseData.instance.getPlayer(uid, withProfile: true),
          builder: (BuildContext context, AsyncSnapshot<Player> data) {
            if (data.hasData) {
              return new ListTile(
                leading: const Icon(Icons.person),
                title: new Text(data.data.name),
                trailing: new IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed:
                      data.data.uid == UserDatabaseData.instance.mePlayer.uid
                          ? null
                          : () => _deleteAdmin(uid, data.data.name),
                ),
              );
            }
            return new ListTile(
              leading: const Icon(Icons.person),
              title: new Text(Messages.of(context).loading),
              trailing: new IconButton(
                icon: const Icon(Icons.delete),
                onPressed: null,
              ),
            );
          },
        ),
      );
    }
    ret.add(
      new FlatButton(
        onPressed: _addAdmin,
        child: new Text("ADD ADMIN"),
        textColor: Theme.of(context).accentColor,
      ),
    );
    ret.add(new StreamBuilder(
      stream: _team.inviteStream,
      builder: (BuildContext context,
          AsyncSnapshot<Iterable<InviteAsAdmin>> admins) {
        Iterable<InviteAsAdmin> invites = _team.invites;
        if (admins.hasData) {
          // Do stuff
          invites = admins.data;
        }
        // Load the existing stuff.
        if (invites != null && invites.length > 0) {
          return new ExpansionTile(
            title:
                new Text(Messages.of(context).pendinginvites(invites.length)),
            children: invites
                .map(
                  (InviteAsAdmin adm) => new ListTile(
                        leading: const Icon(Icons.person_add),
                        title: new Text(adm.email),
                        subtitle:
                            new ByUserNameComponent(userId: adm.sentByUid),
                        trailing: new IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteInvite(adm),
                        ),
                      ),
                )
                .toList(),
          );
        }
        return SizedBox(height: 1.0);
      },
    ));
    return ret;
  }

  List<Widget> _buildBody() {
    List<Widget> ret = <Widget>[];

    _buildAdmins(ret);
    ret.add(
      new SwitchListTile(
        value: _team.trackAttendence,
        title: new Text("Track Attendence"),
        onChanged: (bool attend) => null,
      ),
    );
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return new Column(
      children: <Widget>[
        new Expanded(
          child: new Container(
            constraints: new BoxConstraints(),
            margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            decoration: new BoxDecoration(color: theme.cardColor),
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildBody(),
              ),
            ),
          ),
        )
      ],
    );
  }
}
