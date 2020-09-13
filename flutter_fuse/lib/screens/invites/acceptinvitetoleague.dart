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
  SingleInviteBloc _singleInviteBloc;

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _singleInviteBloc = SingleInviteBloc(
        analytisSubsystem: RepositoryProvider.of<AnalyticsSubsystem>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context),
        seasonBloc: BlocProvider.of<SeasonBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc?.close();
  }

  void _savePressed() async {
    _singleInviteBloc.add(SingleInviteEventAcceptInviteToLeagueAdmin());
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
          child: BlocBuilder(
            cubit: _singleInviteBloc,
            builder: (BuildContext context, SingleInviteState state) {
              if (state is SingleInviteDeleted) {
                // Deleted.
                Navigator.pop(context);
                return Center(child: CircularProgressIndicator());
              } else {
                InviteToLeagueAsAdmin inviteToLeagueAsAdmin =
                    state.invite as InviteToLeagueAsAdmin;

                return Column(
                  children: <Widget>[
                    new ListTile(
                      leading: LeagueImage(
                        leagueOrTournamentUid: inviteToLeagueAsAdmin.leagueUid,
                        width: 50.0,
                        height: 50.0,
                      ),
                      title: new Text(inviteToLeagueAsAdmin.leagueName),
                      subtitle: new ByUserNameComponent(
                          userId: inviteToLeagueAsAdmin.sentByUid),
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
                              context,
                              "/League/Main/" +
                                  inviteToLeagueAsAdmin.leagueUid),
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
