import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

// Shows the current invites pending for this user.
class AcceptInviteAsAdminScreen extends StatefulWidget {
  AcceptInviteAsAdminScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteAsAdminScreenState createState() {
    return new _AcceptInviteAsAdminScreenState();
  }
}

class _AcceptInviteAsAdminScreenState extends State<AcceptInviteAsAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SingleInviteBloc _singleInviteBloc;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

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
    _singleInviteBloc.add(SingleInviteEventAcceptInviteAsAdmin());
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    ThemeData theme = Theme.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: BlocListener(
            cubit: _singleInviteBloc,
            listener: (BuildContext context, SingleInviteState state) {
              if (state is SingleInviteSaveFailed) {
                _showInSnackBar(Messages.of(context).formerror);
              } else if (state is SingleInviteDeleted) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              cubit: _singleInviteBloc,
              builder: (BuildContext context, SingleInviteState state) {
                if (state is SingleInviteDeleted) {
                  // Deleted.
                  return Center(child: CircularProgressIndicator());
                } else {
                  InviteAsAdmin inviteAsAdmin = state.invite as InviteAsAdmin;
                  return SavingOverlay(
                    saving: state is SingleInviteSaving,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                          padding: EdgeInsets.all(10.0),
                          child: new Text(
                            Messages.of(context).acceptinviteasadmin,
                            style: Theme.of(context).textTheme.subhead.copyWith(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(CommunityIcons.tshirtCrew),
                          title: new Text(inviteAsAdmin.teamName),
                          subtitle: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(Messages.of(context).administrator),
                              new ByUserNameComponent(
                                  userId: _singleInviteBloc
                                      .db
                                      .currentUser
                                      .uid),
                            ],
                          ),
                        ),
                        new SizedBox(height: 75.0),
                        new Divider(),
                        new Row(
                          children: <Widget>[
                            new SizedBox(width: 5.0),
                            new RaisedButton(
                              onPressed: _savePressed,
                              child: new Text(messages.addadmin),
                              color: theme.accentColor,
                              textColor: Colors.white,
                            ),
                            new FlatButton(
                              onPressed: () =>
                                  showDeleteInvite(context, _singleInviteBloc),
                              child: new Text(messages.deleteinvitebutton),
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
