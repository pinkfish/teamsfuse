import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/relationshipformfield.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

///
/// Accepts the invite to the player.
///
class AcceptInviteToPlayerScreen extends StatefulWidget {
  AcceptInviteToPlayerScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToPlayerScreenState createState() {
    return new _AcceptInviteToPlayerScreenState();
  }
}

class _AcceptInviteToPlayerScreenState
    extends State<AcceptInviteToPlayerScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Relationship _relationship = Relationship.Friend;
  SingleInviteBloc _singleInviteBloc;

  static const String newInvite = 'new';

  @override
  void initState() {
    super.initState();
    _singleInviteBloc = SingleInviteBloc(
        inviteBloc: BlocProvider.of<InviteBloc>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc.dispose();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _singleInviteBloc.dispatch(SingleInviteEventAcceptInviteToPlayer(
        relationship: _relationship,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return BlocProvider<SingleInviteBloc>(
      bloc: _singleInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: BlocBuilder<SingleInviteEvent, SingleInviteState>(
            bloc: _singleInviteBloc,
            builder: (BuildContext context, SingleInviteState state) {
              if (state is SingleInviteDeleted) {
                return Text(messages.loading);
              } else {
                return Text(messages
                    .followplayer((state.invite as InviteToPlayer).playerName));
              }
            },
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                _savePressed();
              },
              child: new Text(
                messages.savebuttontext,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
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
              child: BlocBuilder<SingleInviteEvent, SingleInviteState>(
                bloc: _singleInviteBloc,
                builder: (BuildContext context, SingleInviteState state) {
                  if (state is SingleInviteDeleted) {
                    // Deleted.
                    Navigator.pop(context);
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SavingOverlay(
                      saving: !(state is SingleInviteLoaded),
                      child: DropdownButtonHideUnderline(
                        child: new Form(
                          key: _formKey,
                          child: new Column(
                            children: <Widget>[
                              new Container(
                                padding: new EdgeInsets.all(20.0),
                                child: new Text(
                                  messages.playerinvitedesc(
                                      (state.invite as InviteToPlayer)
                                          .playerName),
                                ),
                              ),
                              new RelationshipFormField(
                                initialValue: Relationship.Friend,
                                decoration: new InputDecoration(
                                  labelText: messages.relationshipselect,
                                  icon: const Icon(Icons.person),
                                ),
                                onSaved: (Relationship rel) {
                                  _relationship = rel;
                                },
                              ),
                              new Container(
                                padding: new EdgeInsets.only(top: 20.0),
                                child: new ByUserNameComponent(
                                    userId: state.invite.sentByUid),
                              ),
                              new Container(
                                padding: new EdgeInsets.only(top: 20.0),
                                child: ButtonBar(
                                  children: <Widget>[
                                    new RaisedButton(
                                      onPressed: _savePressed,
                                      child: new Text(messages.addplayer),
                                    ),
                                    new FlatButton(
                                      onPressed: () => showDeleteInvite(
                                          context, _singleInviteBloc),
                                      child: new Text(messages.deleteinvite),
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
