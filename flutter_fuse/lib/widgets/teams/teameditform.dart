import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/genderformfield.dart';
import 'package:flutter_fuse/widgets/form/sportformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class TeamEditForm extends StatefulWidget {
  final Team team;

  TeamEditForm(this.team, GlobalKey<TeamEditFormState> key) : super(key: key);

  @override
  TeamEditFormState createState() {
    return new TeamEditFormState(this.team);
  }
}

class TeamEditFormState extends State<TeamEditForm> {
  Team team;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNode = new FocusNode();
  File _imageFile;
  bool _changedImage = false;

  TeamEditFormState(this.team);

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  Future<bool> validateAndSaveToFirebase() async {
    if (!_formKey.currentState.validate()) {
      return false;
    } else {
      _formKey.currentState.save();
      if (_changedImage) {
        await team.updateImage(_imageFile);
      }
      await team.updateFirestore();
    }
    return true;
  }

  void _selectImage() async {
    File imgFile =
        await ImagePicker.pickImage(maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return new TeamImage(team.uid);
    }
    return new Image.file(_imageFile);
  }

  Widget build(BuildContext context) {
    if (team == null) {
      return new Text('Invalid state');
    }

    final Size screenSize = MediaQuery.of(context).size;

    print('uid ${team.toJSON()}');
    return new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Form(
                  key: _formKey,
                  autovalidate: _autovalidate,
                  child: new DropdownButtonHideUnderline(
                      child: new Column(
                    children: <Widget>[
                      new IconButton(
                        onPressed: this._selectImage,
                        iconSize: (screenSize.width < 500)
                            ? 120.0
                            : (screenSize.width / 4) + 12.0,
                        icon: this._buildImage(),
                      ),
                      new EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: new TextFormField(
                            decoration: new InputDecoration(
                              icon: const Icon(Icons.event_note),
                              hintText: Messages.of(context).team,
                              labelText: Messages.of(context).teamnamehint,
                            ),
                            initialValue: team.name,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            onSaved: (String value) {
                              team.name = value;
                            }),
                      ),
                      new SportFormField(
                          decoration: new InputDecoration(
                            icon: const Icon(Icons.people),
                            hintText: Messages.of(context).sportselect,
                            labelText: Messages.of(context).sportselect,
                          ),
                          initialValue: team.sport.toString(),
                          validator: (String value) {
                            _validations.validateSport(context, value);
                          },
                          onSaved: (String value) {
                            team.sport = Sport.values
                                .firstWhere((e) => e.toString() == value);
                          }),
                      new GenderFormField(
                          decoration: new InputDecoration(
                            icon: const Icon(CommunityIcons.gendermalefemale),
                            hintText: Messages.of(context).genderselect,
                            labelText: Messages.of(context).genderselect,
                          ),
                          initialValue: team.gender.toString(),
                          validator: (String value) {
                            _validations.validateGender(context, value);
                          },
                          onSaved: (String value) {
                            team.gender = Gender.values
                                .firstWhere((e) => e.toString() == value);
                          }),
                      new SeasonFormField(
                          decoration: new InputDecoration(
                            icon: const Icon(Icons.calendar_today),
                            hintText: Messages.of(context).seasonselect,
                            labelText: Messages.of(context).seasonselect,
                          ),
                          teamUid: team.uid,
                          initialValue: team.currentSeason,
                          onSaved: (String value) {
                            team.currentSeason = value;
                          }),
                      new EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: new TextFormField(
                            decoration: new InputDecoration(
                              icon: const Icon(Icons.event_note),
                              hintText: Messages.of(context).league,
                              labelText: Messages.of(context).leaguehint,
                            ),
                            initialValue:
                                team.league == null ? '' : team.league,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            onSaved: (String value) {
                              team.league = value;
                            }),
                      ),
                    ],
                  )))
            ]));
  }
}
