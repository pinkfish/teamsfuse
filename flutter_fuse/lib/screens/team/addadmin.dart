import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'dart:async';

class AddAdminScreen extends StatefulWidget {
  AddAdminScreen(this._teamUid);
  final String _teamUid;

  @override
  AddAdminScreenState createState() {
    return new AddAdminScreenState();
  }
}

class AddAdminScreenState extends State<AddAdminScreen> {
  final Validations _validations = new Validations();
  List<String> _emailNames = <String>[];
  bool autovalidate = false;
  bool _saving = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  AddAdminScreenState();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Send the invite, cloud functions will handle the email
      // part of this.
      Team team = UserDatabaseData.instance.teams[widget._teamUid];
      setState(() {
        _saving = true;
      });
      await Future.forEach<String>(_emailNames, (String en) async {
        print("Sending to $en");
        Analytics.analytics
            .logShare(contentType: 'inviteAsAdmin', itemId: team.uid);
        return team.inviteAsAdmin(en);
      });
      setState(() {
        _saving = false;
      });
      Navigator.pop(context);
    } else {
      autovalidate = true;
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  void save() {
    _handleSubmit();
  }

  Widget _buildForm() {
    List<Widget> rows = <Widget>[];
    Messages messages = Messages.of(context);

    if (_emailNames.length == 0) {
      // Add in the start elements.
      _emailNames.add("");
    }
    for (int i = 0; i < _emailNames.length; i++) {
      String en = _emailNames[i];
      rows.add(
        new TextFormField(
          initialValue: '',
          decoration: new InputDecoration(
              icon: const Icon(Icons.email),
              labelText: messages.email,
              hintText: messages.playeremailHint),
          validator: (String value) {
            return _validations.validateEmail(context, value);
          },
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (String value) {
            if (value.isNotEmpty && en.isEmpty && en == _emailNames.last) {
              setState(() {
                _emailNames.add("");
              });
            }
          },
          onSaved: (String value) {
            _emailNames[i] = value;
          },
        ),
      );
    }

    return new SingleChildScrollView(
      child: new Form(
        autovalidate: autovalidate,
        key: _formKey,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Scrollbar(
              child: new SingleChildScrollView(
                child: new Column(children: rows),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).addadmin),
      ),
      body: new SavingOverlay(
        saving: _saving,
        child: _buildForm(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => save(),
        child: const Icon(Icons.check),
      ),
    );
  }
}
