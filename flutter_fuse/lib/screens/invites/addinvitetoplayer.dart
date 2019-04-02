import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  Player _player;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _email;

  static const String newAddInvite = 'new';

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  void initState() {
    super.initState();
    _player = UserDatabaseData.instance.players[widget._playerUid];
    // Default to empty.
    _email = '';
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      InviteBloc inviteBloc = BlocProvider.of<InviteBloc>(context);
      SingleInviteBloc singleInviteBloc =
          SingleInviteBloc(inviteBloc: inviteBloc);
      try {
        singleInviteBloc.dispatch(SingleInviteEventAddInviteToPlayer(
            playerUid: widget._playerUid, email: _email));
        await for (SingleInviteState state in await singleInviteBloc.state) {
          if (state is SingleInviteLoaded) {
            // Yay, we did it.
            Navigator.pop(context);
            break;
          }
          if (state is SingleInviteSaveFailed) {
            showInSnackBar("Error " + state.error.toString());
            break;
          }
        }
      } finally {
        singleInviteBloc.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.followplayer(_player.name)),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _savePressed();
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
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new Form(
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
}
