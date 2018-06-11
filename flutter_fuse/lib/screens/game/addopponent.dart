import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

class AddOpponent extends StatefulWidget {
  AddOpponent(this.teamUid);

  final String teamUid;

  @override
  State createState() {
    Opponent opponent = new Opponent();
    opponent.teamUid = teamUid;

    return new _AddOpponentState(opponent);
  }
}

class _AddOpponentState extends State<AddOpponent> {
  Opponent _opponent;
  FocusNode _focusNode = new FocusNode();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _saving = false;

  _AddOpponentState(this._opponent);

  void _savePressed(BuildContext context) async {
    _formKey.currentState.save();
    setState(() {
      _saving = true;
    });
    await _opponent.updateFirestore();
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
      appBar: new AppBar(
        title: new Text(Messages.of(context).addopponent),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _savePressed(context);
            },
            child: new Text(
              Messages.of(context).savebuttontext,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new SavingOverlay(saving: _saving, child: new Container(
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
