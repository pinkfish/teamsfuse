import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/authentication.dart';
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

  void _deleteAdmin(String adminUid) async {
    Messages mess = Messages.of(context);
    // Show an alert dialog first.
    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteopponent),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(adminUid),
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
      //op.deleteFromFirestore();
    }
  }

  void _addAdmin() {}

  List<Widget> _buildAdmins(List<Widget> ret) {
    ThemeData theme = Theme.of(context);

    ret.add(new Text("Admins", style: theme.textTheme.title));

    for (String uid in _team.admins) {
      print('$uid');
      ret.add(
        new FutureBuilder(
          future: UserAuth.instance.getProfile(uid),
          builder:
              (BuildContext context, AsyncSnapshot<FusedUserProfile> data) {
            if (data.hasData) {
              return new ListTile(
                leading: const Icon(Icons.person),
                title: new Text(data.data.displayName),
                trailing: new IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAdmin(uid),
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
    return ret;
  }

  List<Widget> _buildBody() {
    List<Widget> ret = [];

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
