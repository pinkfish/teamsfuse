import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

class AcceptInviteToLeagueScreen extends StatefulWidget {
  AcceptInviteToLeagueScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToLeagueScreenState createState() {
    return new _AcceptInviteToLeagueScreenState();
  }
}

class _AcceptInviteToLeagueScreenState
    extends State<AcceptInviteToLeagueScreen> {
  InviteToLeagueAsAdmin _invite;
  SingleInviteBloc _singleInviteBloc;

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
      _invite = new InviteToLeagueAsAdmin((var b) => b..leagueUid = '');

      Navigator.pop(context);
    }
    _singleInviteBloc = SingleInviteBloc(
        inviteBloc: BlocProvider.of<InviteBloc>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc?.dispose();
  }

  void _savePressed() async {
    _singleInviteBloc.dispatch(SingleInviteEventAcceptInviteToLeagueAdmin());
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
          child: BlocBuilder<SingleInviteEvent, SingleInviteState>(
            bloc: _singleInviteBloc,
            builder: (BuildContext context, SingleInviteState state) {
              if (state is SingleInviteDeleted) {
                // Deleted.
                Navigator.pop(context);
                return Center(child: CircularProgressIndicator());
              } else if (state is SingleInviteUninitialized) {
                // Loading.
                return Center(child: CircularProgressIndicator());
              } else {
                return Column(
                  children: <Widget>[
                    new ListTile(
                      leading: LeagueImage(
                        leagueOrTournamentUid: _invite.leagueUid,
                        width: 50.0,
                        height: 50.0,
                      ),
                      title: new Text(_invite.leagueName),
                      subtitle:
                          new ByUserNameComponent(userId: _invite.sentByUid),
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
                          onPressed: () =>
                              showDeleteInvite(context, _singleInviteBloc),
                          child: new Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
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
