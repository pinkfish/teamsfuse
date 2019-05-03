import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

// Shows the current invites pending for this user.
class AcceptInviteToClubScreen extends StatefulWidget {
  AcceptInviteToClubScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToClubScreenState createState() {
    return new _AcceptInviteToClubScreenState();
  }
}

class _AcceptInviteToClubScreenState extends State<AcceptInviteToClubScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SingleInviteBloc _singleInviteBloc;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    // Default to empty.
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

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    _singleInviteBloc.dispatch(SingleInviteEventAcceptInviteToClub());
    await for (SingleInviteState state in _singleInviteBloc.state) {
      if (state is SingleInviteSaveFailed) {
        _showInSnackBar(Messages.of(context).formerror);
      } else if (state is SingleInviteDeleted) {
        Navigator.pop(context);
      } else if (state is SingleInviteLoaded) {
        return;
      }
    }
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
            bloc: _singleInviteBloc,
            listener: (BuildContext context, SingleInviteState state) {
              if (state is SingleInviteDeleted) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              bloc: _singleInviteBloc,
              builder: (BuildContext context, SingleInviteState state) {
                if (state is SingleInviteDeleted) {
                  // Deleted.
                  return Center(child: CircularProgressIndicator());
                } else {
                  InviteToClub inviteToClub = state.invite as InviteToClub;
                  return Column(
                    children: <Widget>[
                      new ListTile(
                        leading: const Icon(CommunityIcons.houzz),
                        title: new Text(inviteToClub.clubName),
                        subtitle: new ByUserNameComponent(
                            userId: inviteToClub.sentByUid),
                      ),
                      new Row(
                        children: <Widget>[
                          new RaisedButton(
                            onPressed: _savePressed,
                            child: new Text(messages.addinvite),
                            color: theme.accentColor,
                            textColor: Colors.white,
                          ),
                          new FlatButton(
                            onPressed: () =>
                                showDeleteInvite(context, _singleInviteBloc),
                            child: new Text(messages.deleteinvite),
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
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(),
        child: const Icon(Icons.check),
      ),
    );
  }
}
