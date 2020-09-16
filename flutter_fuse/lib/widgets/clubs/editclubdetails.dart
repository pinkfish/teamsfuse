import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

class EditClubDetailsForm extends StatefulWidget {
  EditClubDetailsForm(this.club, GlobalKey<EditClubDetailsFormState> key)
      : super(key: key);

  final Club club;

  @override
  EditClubDetailsFormState createState() {
    return EditClubDetailsFormState();
  }
}

class EditClubDetailsFormState extends State<EditClubDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = Validations();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeArriveBefore = FocusNode();
  File _imageFile;
  bool _changedImage = false;
  String _clubName;
  int _clubArriveBefore;
  Tristate _clubTrackAttendence = Tristate.Unset;

  @override
  void initState() {
    super.initState();
    _clubTrackAttendence = widget.club.trackAttendence;
    _clubName = widget.club.name;
    _clubArriveBefore = widget.club.arriveBeforeGame;
  }

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  ClubBuilder validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();
      ClubBuilder club = ClubBuilder()
        ..uid = widget.club.uid
        ..name = _clubName
        ..arriveBeforeGame = _clubArriveBefore
        ..trackAttendence = _clubTrackAttendence;

      // club, add in the default admin.
      if (club.uid == null) {
        AuthenticationBloc bloc = BlocProvider.of<AuthenticationBloc>(context);
        club.membersData[bloc.currentUser.uid] =
            AddedOrAdmin((b) => b..admin = true);
      }
      return club;
    }
  }

  File getImageFile() {
    return _imageFile;
  }

  void _selectImage() async {
    File imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return ClubImage(clubUid: widget.club.uid);
    }
    return Image.file(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.club == null) {
      return Text('Invalid state');
    }

    final Size screenSize = MediaQuery.of(context).size;

    List<Widget> fields = <Widget>[
      IconButton(
        onPressed: _selectImage,
        iconSize:
            (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        icon: _buildImage(),
      ),
      EnsureVisibleWhenFocused(
        focusNode: _focusNodeName,
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.event_note),
            hintText: Messages.of(context).team,
            labelText: Messages.of(context).teamnamehint,
          ),
          focusNode: _focusNodeName,
          initialValue: widget.club.name,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (String value) {
            return _validations.validateDisplayName(context, value);
          },
          onSaved: (String value) {
            _clubName = value;
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
          initialValue: widget.club.arriveBeforeGame.toString(),
          keyboardType: TextInputType.number,
          obscureText: false,
          onSaved: (String value) {
            _clubArriveBefore = int.parse(value);
          },
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            autovalidate: _autovalidate,
            child: DropdownButtonHideUnderline(
              child: Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
