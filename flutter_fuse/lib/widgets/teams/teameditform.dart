import 'dart:io';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../form/genderformfield.dart';
import '../form/seasonformfield.dart';
import '../form/sportformfield.dart';
import '../form/switchformfield.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'teamimage.dart';

/// The start section to display.
enum StartSection {
  /// Just the start bits
  start,

  /// Just the end bits.
  end,

  /// all the bits.
  all,
}

///
/// Shows the edit form for the team.  Splits up the team into two
/// sections, the first one shows the start bits and the second the
/// other bits.
///
class TeamEditForm extends StatefulWidget {
  /// Constrcutor.
  TeamEditForm(this.team, this.club, GlobalKey<TeamEditFormState> key,
      {this.startSection = StartSection.all})
      : super(key: key);

  /// The team to use.
  final TeamBuilder team;

  /// The club to use.
  final Club club;

  /// The start section to use.
  final StartSection startSection;

  @override
  TeamEditFormState createState() {
    return TeamEditFormState();
  }
}

///
/// The form state for the team to edit.
///
class TeamEditFormState extends State<TeamEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeNotes = FocusNode();
  final FocusNode _focusNodeSeason = FocusNode();
  final FocusNode _focusNodeArriveBefore = FocusNode();
  Uint8List _imageFile;
  bool _changedImage = false;
  String _seasonName = '';
  TeamBuilder _builder;

  /// Saves all the details to the builder.
  void save() {
    _formKey.currentState.save();
  }

  /// Validates the form.
  bool validate() {
    return _formKey.currentState.validate();
  }

  @override
  void initState() {
    super.initState();
    _builder = widget.team ?? TeamBuilder();
  }

  /// Validates the form and also returns the builder.
  TeamBuilder validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();

      if (_builder.uid == null) {
        var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        // Add the current user as the admin.
        _builder.adminsData[authenticationBloc.currentUser.uid] = BuiltMap.of({
          'added': true,
          'admin': true,
        });
      }
    }
    return _builder;
  }

  /// The name of selected season.
  String get seasonName => _seasonName;

  /// The image file to use, so we can save the image out.
  Uint8List getImageFile() {
    return _imageFile;
  }

  void _selectImage() async {
    var imgFile = await RepositoryProvider.of<ImagePicker>(context).getImage(
        source: ImageSource.gallery, maxHeight: 400.0, maxWidth: 400.0);

    if (imgFile != null) {
      var data = await imgFile.readAsBytes();
      setState(() {
        _imageFile = data;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage(double size) {
    if (!_changedImage) {
      if (_builder.uid == null) {
        return Icon(Icons.upload_file);
      } else {
        return TeamImage(
          teamUid: _builder.uid,
        );
      }
    }
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.cover,
          child: Image.memory(_imageFile),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.team == null) {
      return Text('Invalid state');
    }

    var screenSize = MediaQuery.of(context).size;
    Widget seasonWidget;
    Widget adminWidget;
    Widget adminRelationshipWidget;
    Widget adminNameWidget;
    if (_builder.uid == null) {
      // Adding a team
      seasonWidget = EnsureVisibleWhenFocused(
        focusNode: _focusNodeSeason,
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.calendar_today),
            hintText: Messages.of(context).season,
            labelText: Messages.of(context).seasonhint,
          ),
          focusNode: _focusNodeSeason,
          initialValue: _seasonName,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (value) {
            return _validations.validateSeason(context, value);
          },
          onSaved: (value) {
            _seasonName = value;
            _builder.currentSeason = value;
          },
        ),
      );
    } else {
      seasonWidget = SeasonFormField(
        decoration: InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: Messages.of(context).seasonselect,
          labelText: Messages.of(context).seasonselect,
        ),
        team: _builder.build(),
        initialValue: _builder.currentSeason,
        onSaved: (value) {
          _builder.currentSeason = value;
        },
      );
    }

    var fields = <Widget>[];
    if (widget.startSection != StartSection.end) {
      fields.addAll(<Widget>[
        IconButton(
          onPressed: _selectImage,
          iconSize:
              (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
          icon: _buildImage(
            (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
          ),
        ),
        EnsureVisibleWhenFocused(
          focusNode: _focusNodeName,
          child: TextFormField(
            decoration: InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).team,
              labelText: Messages.of(context).teamNameHint,
            ),
            focusNode: _focusNodeName,
            initialValue: _builder.name,
            keyboardType: TextInputType.text,
            obscureText: false,
            validator: (value) {
              return _validations.validateDisplayName(context, value);
            },
            onSaved: (value) {
              _builder.name = value;
            },
          ),
        ),
        SportFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.people),
            hintText: Messages.of(context).sportselect,
            labelText: Messages.of(context).sportselect,
          ),
          initialValue: _builder.sport ?? Sport.None,
          validator: (value) {
            return _validations.validateSport(context, value);
          },
          onSaved: (value) {
            _builder.sport = value;
          },
        ),
        GenderFormField(
          decoration: InputDecoration(
            icon: const Icon(MdiIcons.genderMaleFemale),
            hintText: Messages.of(context).genderselect,
            labelText: Messages.of(context).genderselect,
          ),
          initialValue: _builder.gender ?? Gender.Female,
          onSaved: (value) {
            _builder.gender = value;
          },
        ),
        seasonWidget,
      ]);
    }
    if (widget.startSection != StartSection.start) {
      fields.addAll(<Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _focusNodeNotes,
          child: TextFormField(
            decoration: InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).league,
              labelText: Messages.of(context).leaguehint,
            ),
            focusNode: _focusNodeNotes,
            initialValue: _builder.league ?? '',
            keyboardType: TextInputType.text,
            obscureText: false,
            onSaved: (value) {
              _builder.league = value;
            },
          ),
        ),
        EnsureVisibleWhenFocused(
          focusNode: _focusNodeArriveBefore,
          child: TextFormField(
            decoration: InputDecoration(
              icon: const Icon(Icons.timer),
              hintText: Messages.of(context).arrivebeforehint,
              labelText: Messages.of(context).arrivebeforelabel,
            ),
            focusNode: _focusNodeArriveBefore,
            initialValue: _builder.arriveEarlyInternal.toString(),
            keyboardType: TextInputType.number,
            obscureText: false,
            onSaved: (value) {
              _builder.arriveEarlyInternal = int.parse(value);
            },
          ),
        ),
        SwitchFormField(
          initialValue: _builder.trackAttendanceInternal ?? true,
          icon: MdiIcons.trafficLight,
          enabled:
              widget.club != null ? widget.club.trackAttendence != null : true,
          label: Messages.of(context).trackattendence(Tristate.Yes),
          onSaved: (value) => _builder.trackAttendanceInternal = value,
        ),
      ]);
      if (widget.club != null) {
        fields.add(
          // Only club teams can be public.
          SwitchFormField(
            initialValue: _builder.isPublic,
            icon: MdiIcons.earth,
            enabled: widget.club != null,
            label: Messages.of(context).publicalyVisible(Tristate.Yes),
            onSaved: (value) => _builder.isPublic = value,
          ),
        );
      }
    }
    if (adminWidget != null) {
      fields.add(adminWidget);
    }
    if (adminNameWidget != null) {
      fields.add(adminNameWidget);
      fields.add(adminRelationshipWidget);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: DropdownButtonHideUnderline(
              child: Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
