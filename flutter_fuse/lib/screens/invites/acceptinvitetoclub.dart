import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../../widgets/util/byusername.dart';
import '../../widgets/util/savingoverlay.dart';
import 'dialog/deleteinvite.dart';

///
/// Accept the invite to the club.
///
class AcceptInviteToClubScreen extends StatefulWidget {
  /// Create the invite screen.
  AcceptInviteToClubScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToClubScreenState createState() {
    return _AcceptInviteToClubScreenState();
  }
}

class _AcceptInviteToClubScreenState extends State<AcceptInviteToClubScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed() async {
    _singleInviteBloc.add(SingleInviteEventAcceptInviteToClub());
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    var theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: BlocListener(
            cubit: _singleInviteBloc,
            listener: (context, state) {
              if (state is SingleInviteSaveFailed) {
                _showInSnackBar(Messages.of(context).formerror);
              } else if (state is SingleInviteDeleted) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              cubit: _singleInviteBloc,
              builder: (context, state) {
                if (state is SingleInviteDeleted) {
                  // Deleted.
                  return Center(child: CircularProgressIndicator());
                } else {
                  var inviteToClub = state.invite as InviteToClub;
                  return SavingOverlay(
                    saving: state is SingleInviteSaving,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(MdiIcons.cardsClub),
                          title: Text(inviteToClub.clubName),
                          subtitle: ByUserNameComponent(
                              userId: inviteToClub.sentByUid),
                        ),
                        Row(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: _savePressed,
                              color: theme.accentColor,
                              textColor: Colors.white,
                              child: Text(messages.addInvite),
                            ),
                            FlatButton(
                              onPressed: () =>
                                  showDeleteInvite(context, _singleInviteBloc),
                              child: Text(messages.deleteinvite),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
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
