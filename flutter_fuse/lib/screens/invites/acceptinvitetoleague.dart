import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/leagueortournament/leagueimage.dart';
import '../../widgets/util/byusername.dart';
import 'dialog/deleteinvite.dart';

///
/// Accept the invite to the leage, displaying the invite and accept flow.
///
class AcceptInviteToLeagueScreen extends StatefulWidget {
  /// Constructor.
  AcceptInviteToLeagueScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToLeagueScreenState createState() {
    return _AcceptInviteToLeagueScreenState();
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
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
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
    var messages = Messages.of(context);

    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).league),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: BlocBuilder(
            bloc: _singleInviteBloc,
            builder: (context, state) {
              if (state is SingleInviteDeleted) {
                // Deleted.
                Navigator.pop(context);
                return Center(child: CircularProgressIndicator());
              } else {
                var inviteToLeagueAsAdmin =
                    state.invite as InviteToLeagueAsAdmin;

                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: LeagueImage(
                        leagueOrTournamentUid: inviteToLeagueAsAdmin.leagueUid,
                        width: 50.0,
                        height: 50.0,
                      ),
                      title: Text(inviteToLeagueAsAdmin.leagueName),
                      subtitle: ByUserNameComponent(
                          userId: inviteToLeagueAsAdmin.sentByUid),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          onPressed: _savePressed,
                          color: theme.accentColor,
                          textColor: Colors.white,
                          child: Text(messages.joinleague),
                        ),
                        FlatButton(
                          onPressed: () => Navigator.pushNamed(context,
                              '/League/Main/${inviteToLeagueAsAdmin.leagueUid}'),
                          child: Text(messages.openbutton),
                        ),
                        FlatButton(
                          onPressed: () =>
                              showDeleteInvite(context, _singleInviteBloc),
                          child: Icon(Icons.delete),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _savePressed,
        child: const Icon(Icons.check),
      ),
    );
  }
}
