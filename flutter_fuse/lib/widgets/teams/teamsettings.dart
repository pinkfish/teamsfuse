import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleplayerprovider.dart';
import '../blocs/singleteamprovider.dart';

class TeamSettings extends StatefulWidget {
  TeamSettings(this._teamUid);

  final String _teamUid;

  @override
  TeamSettingsState createState() {
    return new TeamSettingsState();
  }
}

class TeamSettingsState extends State<TeamSettings> {
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
      InviteBloc inviteBloc = BlocProvider.of<InviteBloc>(context);
      inviteBloc.add(InviteEventDeleteInvite(inviteUid: adminUid));
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
      InviteBloc inviteBloc = BlocProvider.of<InviteBloc>(context);
      inviteBloc.add(InviteEventDeleteInvite(inviteUid: adm.uid));
    }
  }

  void _addAdmin() {
    Navigator.pushNamed(context, "TeamAddAdmin/" + widget._teamUid);
  }

  List<Widget> _buildAdmins(List<Widget> ret, SingleTeamState state) {
    ThemeData theme = Theme.of(context);

    ret.add(new Text("Admins", style: theme.textTheme.title));

    for (String uid in state.team.admins) {
      print('$uid');
      ret.add(
        SinglePlayerProvider(
          playerUid: uid,
          builder: (BuildContext contxt, SinglePlayerBloc bloc) => BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SinglePlayerState state) {
              if (state is SinglePlayerDeleted) {
                return new ListTile(
                  leading: const Icon(Icons.person),
                  title: new Text(Messages.of(context).deleteplayer),
                  trailing: new IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: null,
                  ),
                );
              }
              if (state is SinglePlayerLoaded) {
                return new ListTile(
                  leading: const Icon(Icons.person),
                  title: new Text(state.player.name),
                  trailing: new IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: state.mePlayer
                        ? null
                        : () => _deleteAdmin(uid, state.player.name),
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

    Iterable<InviteAsAdmin> invites = state.invitesAsAdmin;
    // Load the existing stuff.
    if (invites != null && invites.length > 0) {
      ret.add(
        ExpansionTile(
          title: new Text(Messages.of(context).pendinginvites(invites.length)),
          children: invites
              .map(
                (InviteAsAdmin adm) => new ListTile(
                  leading: const Icon(Icons.person_add),
                  title: new Text(adm.email),
                  subtitle: new ByUserNameComponent(userId: adm.sentByUid),
                  trailing: new IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteInvite(adm),
                  ),
                ),
              )
              .toList(),
        ),
      );
    } else {
      ret.add(SizedBox(height: 1.0));
    }

    return ret;
  }

  List<Widget> _buildBody(SingleTeamState state) {
    List<Widget> ret = <Widget>[];

    _buildAdmins(ret, state);
    ret.add(
      new SwitchListTile(
        value: state.team.trackAttendence(state.club),
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
              child: SingleTeamProvider(
                teamUid: widget._teamUid,
                builder: (BuildContext contex, SingleTeamBloc bloc) =>
                    BlocBuilder(
                  cubit: bloc,
                  builder: (BuildContext context, SingleTeamState state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildBody(state),
                    );
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
