import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleteamprovider.dart';

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

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context, SingleTeamBloc singleTeamBloc) async {
    _formKey.currentState.save();
    singleTeamBloc.dispatch(SingleTeamAddOpponent(opponent: _opponent.build()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (BuildContext context, SingleTeamBloc bloc) => Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(Messages.of(context).addopponent),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                _savePressed(context, bloc);
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
          bloc: bloc,
          listener: (BuildContext context, SingleTeamState state) {},
          child: BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, SingleTeamState state) =>
                SavingOverlay(
              saving: state is SingleTeamSaving,
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
          ),
        ),
      ),
    );
  }
}
