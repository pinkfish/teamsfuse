import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/util/byusername.dart';
import '../../widgets/util/savingoverlay.dart';
import 'dialog/deleteinvite.dart';

///
/// Shows the current invites pending for this user.
///
class AcceptInviteAsAdminScreen extends StatefulWidget {
  /// Constrctor.
  AcceptInviteAsAdminScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteAsAdminScreenState createState() {
    return _AcceptInviteAsAdminScreenState();
  }
}

class _AcceptInviteAsAdminScreenState extends State<AcceptInviteAsAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SingleInviteBloc _singleInviteBloc;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

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
    _singleInviteBloc.add(SingleInviteEventAcceptInviteAsAdmin());
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
                  var inviteAsAdmin = state.invite as InviteAsAdmin;
                  return SavingOverlay(
                    saving: state is SingleInviteSaving,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            Messages.of(context).acceptinviteasadmin,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(MdiIcons.tshirtCrew),
                          title: Text(inviteAsAdmin.teamName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Messages.of(context).administrator),
                              ByUserNameComponent(
                                  userId: _singleInviteBloc.db.currentUser.uid),
                            ],
                          ),
                        ),
                        SizedBox(height: 75.0),
                        Divider(),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 5.0),
                            RaisedButton(
                              onPressed: _savePressed,
                              child: Text(messages.addadmin),
                              color: theme.accentColor,
                              textColor: Colors.white,
                            ),
                            FlatButton(
                              onPressed: () =>
                                  showDeleteInvite(context, _singleInviteBloc),
                              child: Text(messages.deleteinvitebutton),
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
    );
  }
}
