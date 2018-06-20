import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class EditClubDetailsForm extends StatefulWidget {
  final Club club;

  EditClubDetailsForm(this.club, GlobalKey<EditClubDetailsFormState> key) : super(key: key);

  @override
  EditClubDetailsFormState createState() {
    return new EditClubDetailsFormState();
  }
}

class EditClubDetailsFormState extends State<EditClubDetailsForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNodeName = new FocusNode();
  FocusNode _focusNodeArriveBefore = new FocusNode();
  File _imageFile;
  bool _changedImage = false;
  String _clubName;
  int _clubArriveBefore;
  bool _clubTrackAttendence;

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  Club validateAndCreate() {
    if (!_formKey.currentState.validate()) {
      return null;
    } else {
      _formKey.currentState.save();
      Club club = new Club(uid: widget.club.uid, name: _clubName, arriveBeforeGame: _clubArriveBefore, trackAttendence: _clubTrackAttendence);

      // New club, add in the default admin.
      if (club.uid == null) {
        club.adminsUids.add(UserDatabaseData.instance.userUid);
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
      return new TeamImage(widget.club.uid);
    }
    return new Image.file(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.club == null) {
      return new Text('Invalid state');
    }

    final Size screenSize = MediaQuery.of(context).size;

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
      new EnsureVisibleWhenFocused(
        focusNode: _focusNodeArriveBefore,
        child: new TextFormField(
          decoration: new InputDecoration(
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

    print('uid ${widget.club.toJson()}');
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
              child: new Column(children: fields),
            ),
          ),
        ],
      ),
    );
  }
}
