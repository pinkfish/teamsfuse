import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class AddOpponent extends StatefulWidget {
  AddOpponent(this.teamUid);

  final String teamUid;

  @override
  State createState() {
    OpponentBuilder opponent = new OpponentBuilder();
    opponent.teamUid = teamUid;

    return new _AddOpponentState(opponent);
  }
}

class _AddOpponentState extends State<AddOpponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _AddOpponentState(this._opponent);

  OpponentBuilder _opponent;
  FocusNode _focusNode = new FocusNode();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _saving = false;
  SingleOpponentBloc _opponentBloc;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void initState() {
    super.initState();
    _opponentBloc = SingleOpponentBloc(
        teamBloc: BlocProvider.of<TeamBloc>(context),
        opponentUid: SingleOpponentBloc.createNew);
  }

  void _savePressed(BuildContext context) async {
    _formKey.currentState.save();
    setState(() {
      _saving = true;
    });
    // Make a new single opponent bloc and wait for stuff.
    _opponentBloc.dispatch(SingleOpponentUpdate(opponent: _opponent));
    // Wait till it is finished.
    await for (SingleOpponentState state in _opponentBloc.state) {
      if (state is SingleOpponentSaveFailed) {
        // Darn it.
        _showInSnackBar(Messages.of(context).formerror);
        return;
      }
      if (state is SingleOpponentLoaded) {
        // Yay!  All good.
        break;
      }
      // Still saving.
    }
    print('updated');
    setState(() {
      _saving = false;
    });

    Navigator.of(context).pop(_opponent.uid);
    print('returning?');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).addopponent),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _savePressed(context);
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
      body: new SavingOverlay(
        saving: _saving,
        child: new Container(
          padding: new EdgeInsets.all(16.0),
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNode,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(Icons.short_text),
                      hintText: Messages.of(context).opponentnamehint,
                      labelText: Messages.of(context).opponentname,
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    onSaved: (String value) {
                      _opponent.name = value;
                    },
                  ),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNode,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(Icons.email),
                      hintText: Messages.of(context).opponentcontacthint,
                      labelText: Messages.of(context).opponentcontact,
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    onSaved: (String value) {
                      _opponent.contact = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
