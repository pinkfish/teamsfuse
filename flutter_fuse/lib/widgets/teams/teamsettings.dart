import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleplayerprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../util/byusername.dart';

class TeamSettings extends StatefulWidget {
  TeamSettings(this._teamUid);

  final String _teamUid;

  @override
  TeamSettingsState createState() {
    return TeamSettingsState();
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
        return AlertDialog(
          title: Text(mess.deleteadmin),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(name),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
        return AlertDialog(
          title: Text(mess.deleteadmininvite),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(adm.email),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
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

    ret.add(Text("Admins", style: theme.textTheme.title));

    for (String uid in state.team.admins) {
      print('$uid');
      ret.add(
        SinglePlayerProvider(
          playerUid: uid,
          builder: (BuildContext contxt, SinglePlayerBloc bloc) => BlocBuilder(
            cubit: bloc,
            builder: (BuildContext context, SinglePlayerState state) {
              if (state is SinglePlayerDeleted) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(Messages.of(context).deleteplayer),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: null,
                  ),
                );
              }
              if (state is SinglePlayerLoaded) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(state.player.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: state.mePlayer
                        ? null
                        : () => _deleteAdmin(uid, state.player.name),
                  ),
                );
              }
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(Messages.of(context).loading),
                trailing: IconButton(
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
      FlatButton(
        onPressed: _addAdmin,
        child: Text("ADD ADMIN"),
        textColor: Theme.of(context).accentColor,
      ),
    );

    Iterable<InviteAsAdmin> invites = state.invitesAsAdmin;
    // Load the existing stuff.
    if (invites != null && invites.length > 0) {
      ret.add(
        ExpansionTile(
          title: Text(Messages.of(context).pendinginvites(invites.length)),
          children: invites
              .map(
                (InviteAsAdmin adm) => ListTile(
                  leading: const Icon(Icons.person_add),
                  title: Text(adm.email),
                  subtitle: ByUserNameComponent(userId: adm.sentByUid),
                  trailing: IconButton(
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
      SwitchListTile(
        value: state.team.trackAttendence(state.club),
        title: Text("Track Attendence"),
        onChanged: (bool attend) => null,
      ),
    );
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            constraints: BoxConstraints(),
            margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            decoration: BoxDecoration(color: theme.cardColor),
            child: SingleChildScrollView(
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
