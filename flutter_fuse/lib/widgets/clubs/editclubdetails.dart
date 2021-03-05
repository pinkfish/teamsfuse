import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'clubimage.dart';

///
/// A form to edit the details of the club.
///
class EditClubDetailsForm extends StatefulWidget {
  /// Constructor.
  EditClubDetailsForm(this.club, GlobalKey<EditClubDetailsFormState> key)
      : super(key: key);

  /// The club to edit the details of.
  final Club club;

  @override
  EditClubDetailsFormState createState() {
    return EditClubDetailsFormState();
  }
}

///
/// State for editing the details of the club and doing stuff.
///
class EditClubDetailsFormState extends State<EditClubDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _autovalidate = false;
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeArriveBefore = FocusNode();
  final FocusNode _focusNodeAbout = FocusNode();
  Uint8List _imageFile;
  bool _changedImage = false;
  String _clubName;
  String _clubAbout;
  int _clubArriveBefore;
  Tristate _clubTrackAttendence = Tristate.Unset;

  @override
  void initState() {
    super.initState();
    _clubTrackAttendence = widget.club.trackAttendence;
    _clubName = widget.club.name;
    _clubArriveBefore = widget.club.arriveBeforeGame;
  }

  /// Save the club details.
  void save() {
    _formKey.currentState.save();
  }

  /// validate the club details.
  bool validate() {
    return _formKey.currentState.validate();
  }

  /// Validate the details and create the club for saving.
  ClubBuilder validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();
      var club = widget.club.toBuilder()
        ..name = _clubName
        ..about = _clubAbout
        ..arriveBeforeGame = _clubArriveBefore
        ..trackAttendence = _clubTrackAttendence;

      // club, add in the default admin.
      if (club.uid == null) {
        var bloc = BlocProvider.of<AuthenticationBloc>(context);
        club.membersData[bloc.currentUser.uid] =
            AddedOrAdmin((b) => b..admin = true);
      }
      return club;
    }
  }

  /// Get the image file associated with this club.
  Uint8List getImageFile() {
    return _imageFile;
  }

  void _selectImage() async {
    var imgFile = await RepositoryProvider.of<ImagePicker>(context).getImage(
        source: ImageSource.gallery, maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      var data = await imgFile.readAsBytes();

      setState(() {
        _imageFile = data;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return ClubImage(clubUid: widget.club.uid);
    }
    return Image.memory(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.club == null) {
      return Text('Invalid state');
    }

    var screenSize = MediaQuery.of(context).size;

    var fields = <Widget>[
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
            icon: const Icon(Icons.text_snippet_outlined),
            hintText: Messages.of(context).team,
            labelText: Messages.of(context).teamNameHint,
          ),
          focusNode: _focusNodeName,
          initialValue: widget.club.name,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (value) {
            return _validations.validateDisplayName(context, value);
          },
          onSaved: (value) {
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
          onSaved: (value) {
            _clubArriveBefore = int.parse(value);
          },
        ),
      ),
      EnsureVisibleWhenFocused(
        focusNode: _focusNodeAbout,
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.text_snippet_outlined),
            hintText: Messages.of(context).team,
            labelText: Messages.of(context).teamNameHint,
          ),
          focusNode: _focusNodeAbout,
          initialValue: widget.club.about,
          keyboardType: TextInputType.text,
          obscureText: false,
          maxLines: 4,
          validator: (value) {
            return _validations.validateDisplayName(context, value);
          },
          onSaved: (value) {
            _clubAbout = value;
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
