import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/genderformfield.dart';
import 'package:flutter_fuse/widgets/form/sportformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class TeamEditForm extends StatefulWidget {
  final Team team;

  TeamEditForm(this.team, GlobalKey<TeamEditFormState> key) : super(key: key);

  @override
  TeamEditFormState createState() {
    return new TeamEditFormState();
  }
}

class TeamEditFormState extends State<TeamEditForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNodeName = new FocusNode();
  FocusNode _focusNodeNotes = new FocusNode();
  FocusNode _focusNodeSeason = new FocusNode();
  FocusNode _focusNodeArriveBefore = new FocusNode();
  File _imageFile;
  bool _changedImage = false;
  String _seasonName = "";
  bool _saving = false;

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  Team validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();

      if (widget.team.uid == null) {
        // Add the current user as the admin.
        widget.team.admins.add(UserDatabaseData.instance.userUid);
        Season season = new Season();
        season.name = _seasonName;
        season.record = new WinRecord();
        season.teamUid = widget.team.precreateUid();
        widget.team.seasons[season.precreateUid()] = season;
        widget.team.currentSeason = season.precreateUid();
      }
    }
    return widget.team;
  }

  File getImageFile() {
    return _imageFile;
  }

  Future<bool> validateAndSaveToFirebase() async {
    if (!_formKey.currentState.validate()) {
      return false;
    } else {
      _formKey.currentState.save();
      setState(() {
        _saving = true;
      });
      try {
        if (widget.team.uid == null) {
          // Add the current user as the admin.
          widget.team.admins.add(UserDatabaseData.instance.userUid);
          Season season = new Season();
          season.name = _seasonName;
          season.record = new WinRecord();
          season.teamUid = widget.team.precreateUid();
          await season.updateFirestore(includePlayers: true);
          widget.team.currentSeason = season.uid;
        }
        await widget.team.updateFirestore();
        if (_changedImage) {
          await widget.team.updateImage(_imageFile);
        }
      } finally {
        setState(() {
          _saving = false;
        });
      }
    }
    return true;
  }

  void _selectImage() async {
    File imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 400.0, maxWidth: 400.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return new TeamImage(team: widget.team);
    }
    return new Image.file(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.team == null) {
      return new Text('Invalid state');
    }

    Club club;
    if (widget.team.clubUid != null) {
      club = UserDatabaseData.instance.clubs[widget.team.clubUid];
    }
    final Size screenSize = MediaQuery.of(context).size;
    Widget seasonWidget;
    Widget adminWidget;
    Widget adminRelationshipWidget;
    Widget adminNameWidget;
    if (widget.team.uid == null) {
      // Adding a team
      seasonWidget = new EnsureVisibleWhenFocused(
        focusNode: _focusNodeSeason,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.calendar_today),
            hintText: Messages.of(context).season,
            labelText: Messages.of(context).seasonhint,
          ),
          focusNode: _focusNodeSeason,
          initialValue: _seasonName,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (String value) {
            return _validations.validateSeason(context, value);
          },
          onSaved: (String value) {
            _seasonName = value;
          },
        ),
      );
    } else {
      seasonWidget = new SeasonFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: Messages.of(context).seasonselect,
          labelText: Messages.of(context).seasonselect,
        ),
        teamUid: widget.team.uid,
        initialValue: widget.team.currentSeason,
        onSaved: (String value) {
          widget.team.currentSeason = value;
        },
      );
    }

    List<Widget> fields = <Widget>[
      new IconButton(
        onPressed: _selectImage,
        iconSize:
            (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        icon: _buildImage(),
      ),
      new EnsureVisibleWhenFocused(
        focusNode: _focusNodeName,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.event_note),
            hintText: Messages.of(context).team,
            labelText: Messages.of(context).teamnamehint,
          ),
          focusNode: _focusNodeName,
          initialValue: widget.team.name,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (String value) {
            return _validations.validateDisplayName(context, value);
          },
          onSaved: (String value) {
            widget.team.name = value;
          },
        ),
      ),
      new SportFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.people),
          hintText: Messages.of(context).sportselect,
          labelText: Messages.of(context).sportselect,
        ),
        initialValue: widget.team.sport,
        validator: (Sport value) {
          return _validations.validateSport(context, value);
        },
        onSaved: (Sport value) {
          widget.team.sport = value;
        },
      ),
      new GenderFormField(
        decoration: new InputDecoration(
          icon: const Icon(CommunityIcons.genderMaleFemale),
          hintText: Messages.of(context).genderselect,
          labelText: Messages.of(context).genderselect,
        ),
        initialValue: widget.team.gender,
        onSaved: (Gender value) {
          widget.team.gender = value;
        },
      ),
      seasonWidget,
      new EnsureVisibleWhenFocused(
        focusNode: _focusNodeNotes,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.event_note),
            hintText: Messages.of(context).league,
            labelText: Messages.of(context).leaguehint,
          ),
          focusNode: _focusNodeNotes,
          initialValue: widget.team.league == null ? '' : widget.team.league,
          keyboardType: TextInputType.text,
          obscureText: false,
          onSaved: (String value) {
            widget.team.league = value;
          },
        ),
      ),
      new EnsureVisibleWhenFocused(
        focusNode: _focusNodeArriveBefore,
        child: new TextFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.timer),
            hintText: Messages.of(context).arrivebeforehint,
            labelText: Messages.of(context).arrivebeforelabel,
          ),
          focusNode: _focusNodeArriveBefore,
          initialValue: widget.team.arriveEarly.toString(),
          keyboardType: TextInputType.number,
          obscureText: false,
          onSaved: (String value) {
            widget.team.arriveEarly = int.parse(value);
          },
        ),
      ),
      new SwitchFormField(
        initialValue: widget.team.trackAttendence,
        icon: CommunityIcons.trafficLight,
        enabled: club != null ? club.trackAttendence != null : true,
        label: Messages.of(context).trackattendence(Tristate.Yes),
        onSaved: (bool value) => widget.team.trackAttendence = value,
      ),
    ];
    if (adminWidget != null) {
      fields.add(adminWidget);
    }
    if (adminNameWidget != null) {
      fields.add(adminNameWidget);
      fields.add(adminRelationshipWidget);
    }

    print('uid ${widget.team.toJSON()}');
    return SavingOverlay(
      saving: _saving,
      child: new SingleChildScrollView(
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
                child: new Column(children: fields),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
