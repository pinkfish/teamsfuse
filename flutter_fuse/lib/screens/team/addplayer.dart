import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/roleinteamformfield.dart';
import 'dart:async';

class AddPlayerScreen extends StatefulWidget {
  AddPlayerScreen(this._teamUid, this._seasonUid);

  final String _teamUid;
  final String _seasonUid;

  @override
  AddPlayerScreenState createState() {
    return new AddPlayerScreenState(this._teamUid, this._seasonUid);
  }
}

class EmailName {
  final GlobalKey<FormFieldState<String>> nameKey =
      new GlobalKey<FormFieldState<String>>();
  String email = '';
  String name = '';
  RoleInTeam role = RoleInTeam.NonPlayer;
}

class AddPlayerScreenState extends State<AddPlayerScreen> {
  final String _teamUid;
  String _seasonUid;
  final Validations _validations = new Validations();
  List<EmailName> _emailNames = new List<EmailName>();
  bool autovalidate = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  AddPlayerScreenState(this._teamUid, this._seasonUid);

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
      Team team = UserDatabaseData.instance.teams[_teamUid];
      Season season = team.seasons[_seasonUid];
      UserData user = await UserAuth.instance.currentUser();
      await Future.forEach<EmailName>(_emailNames, (EmailName en) async {
        return season.inviteUser(
            email: en.email, playername: en.name, userId: user.uid);
      });
      Navigator.pop(context);
    } else {
      autovalidate = true;
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildForm() {
    List<Widget> rows = new List<Widget>();
    Messages messages = Messages.of(context);

    rows.add(
      new DropdownButtonHideUnderline(
        child: new SeasonFormField(
          initialValue: _seasonUid,
          teamUid: _teamUid,
          onSaved: (String value) {
            _seasonUid = value;
          },
        ),
      ),
    );

    if (_emailNames.length == 0) {
      // Add in the start elements.
      _emailNames.add(new EmailName());
    }
    _emailNames.forEach(
      (EmailName en) {
        rows.add(
          new TextFormField(
            key: en.nameKey,
            initialValue: '',
            decoration: new InputDecoration(
                icon: const Icon(Icons.person),
                labelText: messages.displayname,
                hintText: messages.displaynamehint),
            validator: (String value) {
              return _validations.validateDisplayName(context, value);
            },
            keyboardType: TextInputType.text,
            onSaved: (String value) {
              en.name = value;
            },
          ),
        );

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
              if (value.isNotEmpty &&
                  en.nameKey.currentState.value.isNotEmpty &&
                  en == _emailNames.last) {
                setState(() {
                  _emailNames.add(new EmailName());
                });
              }
            },
            onSaved: (String value) {
              en.email = value;
            },
          ),
        );

        rows.add(
          new RoleInTeamFormField(
            initialValue: 'none',
            decoration: new InputDecoration(
              icon: const Icon(Icons.message),
              labelText: messages.roleselect,
            ),
            validator: (String val) {
              _validations.validateRoleInTeam(context, val);
            },
            onSaved: (String val) {
              en.role =
                  RoleInTeam.values.firstWhere((e) => e.toString() == val);
            },
          ),
        );
      },
    );

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
            new FlatButton(
              onPressed: _handleSubmit,
              child: new Text(Messages.of(context).addplayer),
            )
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
        title: new Text(Messages.of(context).addplayer),
      ),
      body: _buildForm(),
    );
  }
}
