import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/form/relationshipformfield.dart';
import '../../widgets/util/byusername.dart';
import '../../widgets/util/savingoverlay.dart';
import 'dialog/deleteinvite.dart';

///
/// Accepts the invite to the player.
///
class AcceptInviteToPlayerScreen extends StatefulWidget {
  /// Constructor.
  AcceptInviteToPlayerScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToPlayerScreenState createState() {
    return _AcceptInviteToPlayerScreenState();
  }
}

class _AcceptInviteToPlayerScreenState
    extends State<AcceptInviteToPlayerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Relationship _relationship = Relationship.Friend;
  SingleInviteBloc _singleInviteBloc;

  @override
  void initState() {
    super.initState();
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
    _singleInviteBloc.close();
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _singleInviteBloc.add(SingleInviteEventAcceptInviteToPlayer(
        relationship: _relationship,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return BlocProvider<SingleInviteBloc>.value(
      value: _singleInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: BlocBuilder(
            cubit: _singleInviteBloc,
            builder: (context, state) {
              if (state is SingleInviteDeleted) {
                return Text(messages.loading);
              } else {
                return Text(messages
                    .followplayer((state.invite as InviteToPlayer).playerName));
              }
            },
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _savePressed();
              },
              child: Text(
                messages.savebuttontext,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: BlocListener(
              cubit: _singleInviteBloc,
              listener: (context, state) {
                if (state is SingleInviteDeleted) {
                  Navigator.pop(context);
                }
              },
              child: BlocBuilder(
                cubit: _singleInviteBloc,
                builder: (context, state) {
                  if (state is SingleInviteDeleted) {
                    // Deleted.
                    Navigator.pop(context);
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SavingOverlay(
                      saving: !(state is SingleInviteLoaded),
                      child: DropdownButtonHideUnderline(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  messages.playerInviteDesc(
                                      (state.invite as InviteToPlayer)
                                          .playerName),
                                ),
                              ),
                              RelationshipFormField(
                                initialValue: Relationship.Friend,
                                decoration: InputDecoration(
                                  labelText: messages.relationshipselect,
                                  icon: const Icon(Icons.person),
                                ),
                                onSaved: (rel) {
                                  _relationship = rel;
                                },
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20.0),
                                child: ByUserNameComponent(
                                    userId: state.invite.sentByUid),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20.0),
                                child: ButtonBar(
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: _savePressed,
                                      child: Text(messages.addplayer),
                                    ),
                                    FlatButton(
                                      onPressed: () => showDeleteInvite(
                                          context, _singleInviteBloc),
                                      child: Text(messages.deleteinvite),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
