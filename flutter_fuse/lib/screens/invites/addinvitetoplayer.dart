import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleplayerprovider.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Adds an invite to a player, displaying the invite and accept flow.
///
class AddInviteToPlayerScreen extends StatefulWidget {
  /// Constructor.
  AddInviteToPlayerScreen(this._playerUid);

  final String _playerUid;

  @override
  _AddInviteToPlayerScreenState createState() {
    return _AddInviteToPlayerScreenState();
  }
}

class _AddInviteToPlayerScreenState extends State<AddInviteToPlayerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  AddInviteBloc addInviteBloc;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
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
    var messages = Messages.of(context);

    return BlocProvider(
      create: (c) => addInviteBloc,
      child: SinglePlayerProvider(
        playerUid: widget._playerUid,
        builder: (context, playerBloc) => Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(messages.followPlayer(
                playerBloc.state?.player?.name ?? messages.loading)),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _savePressed(playerBloc.state);
                },
                child: Text(
                  Messages.of(context).saveButtonText,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          body: BlocListener(
            cubit: addInviteBloc,
            listener: (c, addState) {
              if (addState is AddItemDone) {
                Navigator.pop(context);
              }
              if (addState is AddItemSaveFailed) {
                showInSnackBar("Error ${addState.error.toString()}");
              }
            },
            child: BlocBuilder(
              cubit: addInviteBloc,
              builder: (c, addState) => BlocBuilder(
                cubit: playerBloc,
                builder: (context, state) {
                  if (state is SinglePlayerLoaded) {
                    return Scrollbar(
                      child: SingleChildScrollView(
                        child: SavingOverlay(
                          saving: addState is AddItemSaving,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: messages.email,
                                    hintText: messages.playeremailHint,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: _email,
                                  onSaved: (newName) {
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
