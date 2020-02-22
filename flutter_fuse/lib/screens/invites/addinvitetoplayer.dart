import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';

import '../../widgets/blocs/singleplayerprovider.dart';

// Shows the current invites pending for this user.
class AddInviteToPlayerScreen extends StatefulWidget {
  AddInviteToPlayerScreen(this._playerUid);

  final String _playerUid;

  @override
  _AddInviteToPlayerScreenState createState() {
    return new _AddInviteToPlayerScreenState();
  }
}

class _AddInviteToPlayerScreenState extends State<AddInviteToPlayerScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _email;
  AddInviteBloc addInviteBloc;

  static const String newAddInvite = 'new';

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _email = '';
    addInviteBloc = AddInviteBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _savePressed(SinglePlayerState state) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      addInviteBloc.add(InviteEventAddUserToPlayer(
          email: _email,
          playerUid: widget._playerUid,
          playerName: state.player.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return BlocProvider(
      create: (BuildContext c) => addInviteBloc,
      child: SinglePlayerProvider(
        playerUid: widget._playerUid,
        builder: (BuildContext context, SinglePlayerBloc playerBloc) =>
            Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text(messages.followplayer(
                playerBloc.state?.player?.name ?? messages.loading)),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  _savePressed(playerBloc.state);
                },
                child: new Text(
                  Messages.of(context).savebuttontext,
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          body: BlocListener(
            bloc: addInviteBloc,
            listener: (BuildContext c, AddItemState addState) {
              if (addState is AddItemDone) {
                Navigator.pop(context);
              }
              if (addState is AddItemSaveFailed) {
                showInSnackBar("Error " + addState.error.toString());
              }
            },
            child: BlocBuilder(
              bloc: addInviteBloc,
              builder: (BuildContext c, AddItemState addState) => BlocBuilder(
                bloc: playerBloc,
                builder: (BuildContext context, SinglePlayerState state) {
                  if (state is SinglePlayerLoaded) {
                    return Scrollbar(
                      child: new SingleChildScrollView(
                        child: SavingOverlay(
                          saving: addState is AddItemSaving,
                          child: Form(
                            key: _formKey,
                            child: new Column(
                              children: <Widget>[
                                new TextFormField(
                                  decoration: new InputDecoration(
                                    labelText: messages.email,
                                    hintText: messages.playeremailHint,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: _email,
                                  onSaved: (String newName) {
                                    _email = newName.toLowerCase();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Text(messages.loading);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
