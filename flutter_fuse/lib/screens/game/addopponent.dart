import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add an opponent to the specific team.
///
class AddOpponent extends StatefulWidget {
  /// Constructore with the team to add tne opponent too.
  AddOpponent(this.teamUid);

  /// TeamUid to add the opponent too.
  final String teamUid;

  @override
  State createState() {
    var opponent = OpponentBuilder();
    opponent.teamUid = teamUid;

    return _AddOpponentState(opponent);
  }
}

class _AddOpponentState extends State<AddOpponent> {
  _AddOpponentState(this._opponent);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final OpponentBuilder _opponent;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _savePressed(BuildContext context, SingleTeamBloc singleTeamBloc) async {
    _formKey.currentState.save();
    singleTeamBloc.add(SingleTeamAddOpponent(opponent: _opponent.build()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (context, bloc) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Messages.of(context).addopponent),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _savePressed(context, bloc);
              },
              child: Text(
                Messages.of(context).savebuttontext,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        body: BlocListener(
          cubit: bloc,
          listener: (context, state) {},
          child: BlocBuilder(
            cubit: bloc,
            builder: (context, state) => SavingOverlay(
              saving: state is SingleTeamSaving,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.short_text),
                            hintText: Messages.of(context).opponentnamehint,
                            labelText: Messages.of(context).opponentname,
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          onSaved: (value) {
                            _opponent.name = value;
                          },
                        ),
                      ),
                      EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.email),
                            hintText: Messages.of(context).opponentcontacthint,
                            labelText: Messages.of(context).opponentcontact,
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          onSaved: (value) {
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
