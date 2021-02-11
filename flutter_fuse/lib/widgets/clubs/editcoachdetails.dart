import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../util/ensurevisiblewhenfocused.dart';
import 'clubimage.dart';
import 'coachimage.dart';

///
/// A form to edit the details of the club.
///
class EditCoachDetailsForm extends StatefulWidget {
  /// Constructor.
  EditCoachDetailsForm(
      this.club, this.coach, GlobalKey<EditCoachDetailsFormState> key)
      : super(key: key);

  /// The club the coach is part of.
  final Club club;

  /// The club to edit the details of.
  final Coach coach;

  @override
  EditCoachDetailsFormState createState() {
    return EditCoachDetailsFormState();
  }
}

///
/// State for editing the details of the club and doing stuff.
///
class EditCoachDetailsFormState extends State<EditCoachDetailsForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _autovalidate = false;
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeAbout = FocusNode();
  final _picker = ImagePicker();
  Uint8List _imageFile;
  bool _changedImage = false;
  String _coachName;
  String _coachAbout;

  @override
  void initState() {
    super.initState();
    _coachName = widget.coach.name;
    _coachAbout = widget.coach.about;
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
  CoachBuilder validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();
      var coach = widget.coach.toBuilder()
        ..name = _coachName
        ..about = _coachAbout;

      // club, add in the default admin.
      return coach;
    }
  }

  /// Get the image file associated with this club.
  Uint8List getImageFile() {
    return _imageFile;
  }

  void _selectImage() async {
    var imgFile = await _picker.getImage(
        source: ImageSource.gallery, maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      _imageFile = await imgFile.readAsBytes();
      setState(() {
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return CoachImage(
          clubUid: widget.club.uid,
          coachUid: widget.coach.uid,
          width: 100,
          height: 100);
    }
    return ClipOval(
      child: Image.memory(_imageFile),
    );
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
            hintText: Messages.of(context).coachNameHint,
            labelText: Messages.of(context).coachName,
          ),
          focusNode: _focusNodeName,
          initialValue: widget.coach.name,
          keyboardType: TextInputType.text,
          obscureText: false,
          validator: (value) {
            return _validations.validateDisplayName(context, value);
          },
          onSaved: (value) {
            _coachName = value;
          },
        ),
      ),
      EnsureVisibleWhenFocused(
        focusNode: _focusNodeAbout,
        child: TextFormField(
          decoration: InputDecoration(
            icon: const Icon(Icons.info_outline),
            hintText: Messages.of(context).coachAboutHint,
            labelText: Messages.of(context).coachAbout,
          ),
          focusNode: _focusNodeAbout,
          initialValue: widget.coach.about,
          keyboardType: TextInputType.text,
          maxLines: 4,
          obscureText: false,
          onSaved: (value) {
            _coachAbout = value;
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
          ListTile(
            leading: ClubImage(clubUid: widget.club.uid),
            title: Text(
              widget.club.name,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Form(
            key: _formKey,
            autovalidateMode: _autovalidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: DropdownButtonHideUnderline(
              child: Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
