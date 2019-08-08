import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/genderformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/sportformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

enum StartSection { start, end, all }

///
/// Shows the edit form for the team.  Splits up the team into two
/// sections, the first one shows the start bits and the second the
/// other bits.
///
class TeamEditForm extends StatefulWidget {
  TeamEditForm(this.team, GlobalKey<TeamEditFormState> key,
      {this.startSection = StartSection.all})
      : super(key: key);

  final Team team;
  final StartSection startSection;

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
  TeamBuilder builder;

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  @override
  void initState() {
    builder = widget.team.toBuilder();
  }

  TeamBuilder validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();

      if (builder.uid == null) {
        AuthenticationBloc authenticationBloc =
            BlocProvider.of<AuthenticationBloc>(context);
        // Add the current user as the admin.
        builder.admins.add(authenticationBloc.currentUser.uid);
      }
    }
    return builder;
  }

  String get seasonName => _seasonName;

  File getImageFile() {
    return _imageFile;
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
      return new TeamImage(
        teamUid: builder.uid,
      );
    }
    return new Image.file(_imageFile);
  }

  Widget _buildBody(Team team) {}

  @override
  Widget build(BuildContext context) {
    ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);
    if (widget.team == null) {
      return new Text('Invalid state');
    }

    Club club;
    if (widget.team.clubUid != null) {
      if (clubBloc.currentState.clubs.containsKey(widget.team.clubUid)) {
        club = clubBloc.currentState.clubs[widget.team.clubUid];
      }
    }
    final Size screenSize = MediaQuery.of(context).size;
    Widget seasonWidget;
    Widget adminWidget;
    Widget adminRelationshipWidget;
    Widget adminNameWidget;
    if (builder.uid == null) {
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
        team: builder.build(),
        initialValue: builder.currentSeason,
        onSaved: (String value) {
          builder.currentSeason = value;
        },
      );
    }

    List<Widget> fields = <Widget>[];
    if (widget.startSection != StartSection.end) {
      fields.addAll(<Widget>[
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
            initialValue: builder.name,
            keyboardType: TextInputType.text,
            obscureText: false,
            validator: (String value) {
              return _validations.validateDisplayName(context, value);
            },
            onSaved: (String value) {
              builder.name = value;
            },
          ),
        ),
        new SportFormField(
          decoration: new InputDecoration(
            icon: const Icon(Icons.people),
            hintText: Messages.of(context).sportselect,
            labelText: Messages.of(context).sportselect,
          ),
          initialValue: builder.sport,
          validator: (Sport value) {
            return _validations.validateSport(context, value);
          },
          onSaved: (Sport value) {
            builder.sport = value;
          },
        ),
        new GenderFormField(
          decoration: new InputDecoration(
            icon: const Icon(CommunityIcons.genderMaleFemale),
            hintText: Messages.of(context).genderselect,
            labelText: Messages.of(context).genderselect,
          ),
          initialValue: builder.gender,
          onSaved: (Gender value) {
            builder.gender = value;
          },
        ),
        seasonWidget,
      ]);
    }
    if (widget.startSection != StartSection.start) {
      fields.addAll(<Widget>[
        new EnsureVisibleWhenFocused(
          focusNode: _focusNodeNotes,
          child: new TextFormField(
            decoration: new InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).league,
              labelText: Messages.of(context).leaguehint,
            ),
            focusNode: _focusNodeNotes,
            initialValue: builder.league == null ? '' : builder.league,
            keyboardType: TextInputType.text,
            obscureText: false,
            onSaved: (String value) {
              builder.league = value;
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
            initialValue: builder.arriveEarlyInternal.toString(),
            keyboardType: TextInputType.number,
            obscureText: false,
            onSaved: (String value) {
              builder.arriveEarlyInternal = int.parse(value);
            },
          ),
        ),
        new SwitchFormField(
          initialValue: builder.trackAttendenceInternal,
          icon: CommunityIcons.trafficLight,
          enabled: club != null ? club.trackAttendence != null : true,
          label: Messages.of(context).trackattendence(Tristate.Yes),
          onSaved: (bool value) => builder.trackAttendenceInternal = value,
        ),
      ]);
    }
    if (adminWidget != null) {
      fields.add(adminWidget);
    }
    if (adminNameWidget != null) {
      fields.add(adminNameWidget);
      fields.add(adminRelationshipWidget);
    }

    return new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: new DropdownButtonHideUnderline(
              child: new Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
