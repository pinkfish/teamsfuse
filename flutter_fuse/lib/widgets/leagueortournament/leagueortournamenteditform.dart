import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/form/sportformfield.dart';
import 'package:flutter_fuse/widgets/form/genderformfield.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// This form has all the stuff needed to edit the main parts
// of the game.  Does not have the add game step flow.
class LeagueOrTournamentEditForm extends StatefulWidget {
  LeagueOrTournamentEditForm(
      {@required this.leagueOrTournament,
      @required GlobalKey<LeagueOrTournamentEditFormState> key})
      : super(key: key);

  final LeagueOrTournament leagueOrTournament;

  @override
  LeagueOrTournamentEditFormState createState() {
    return new LeagueOrTournamentEditFormState();
  }
}

class LeagueOrTournamentEditFormState
    extends State<LeagueOrTournamentEditForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNodeName = new FocusNode();
  FocusNode _focusNodeShortDescription = new FocusNode();
  FocusNode _focusNodeLongDescription = new FocusNode();
  bool _changedImage = false;
  File _imageFile;

  @override
  void save() {
    _formKey.currentState.save();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
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
      return new LeagueImage(leagueOrTournament: widget.leagueOrTournament);
    }
    return new Image.file(_imageFile);
  }

  File get imageFile {
    if (_changedImage) {
      return _imageFile;
    }
    return null;
  }

  LeagueOrTournament get finalLeagueOrTournamentResult {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return null;
    } else {
      _formKey.currentState.save();
      print(widget.leagueOrTournament);
      // Add the date time and the time together.
      return widget.leagueOrTournament;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.leagueOrTournament.uid != null &&
        !UserDatabaseData.instance.leagueOrTournments
            .containsKey(widget.leagueOrTournament.uid)) {
      return new Text('Invalid state ${widget.leagueOrTournament.uid}');
    }

    final Size screenSize = MediaQuery.of(context).size;

    return new Scrollbar(
      child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Form(
          key: _formKey,
          autovalidate: autovalidate,
          child: new DropdownButtonHideUnderline(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new IconButton(
                  onPressed: _selectImage,
                  iconSize: (screenSize.width < 500)
                      ? 120.0
                      : (screenSize.width / 4) + 12.0,
                  icon: _buildImage(),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeName,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(CommunityIcons.textbox),
                      hintText: Messages.of(context).league,
                    ),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodeName,
                    obscureText: false,
                    validator: (String str) =>
                        _validations.validateName(context, str),
                    initialValue: widget.leagueOrTournament.name,
                    onSaved: (String value) {
                      widget.leagueOrTournament.name = value;
                    },
                  ),
                ),
                new GenderFormField(
                  decoration: InputDecoration(
                    icon: const Icon(CommunityIcons.genderTransgender),
                    hintText: Messages.of(context).needtoselectgender,
                  ),
                  initialValue: widget.leagueOrTournament.gender,
                  onSaved: (Gender g) {
                    widget.leagueOrTournament.gender = g;
                  },
                ),
                new SportFormField(
                  decoration: InputDecoration(
                    icon: const Icon(CommunityIcons.basketball),
                  ),
                  initialValue: widget.leagueOrTournament.sport,
                  onSaved: (Sport s) {
                    widget.leagueOrTournament.sport = s;
                  },
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeShortDescription,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(CommunityIcons.textShort),
                      hintText: Messages.of(context).shortDescriptionHint,
                      labelText: Messages.of(context).shortDescription,
                    ),
                    keyboardType: TextInputType.text,
                    focusNode: _focusNodeShortDescription,
                    obscureText: false,
                    initialValue: widget.leagueOrTournament.shortDescription,
                    onSaved: (String value) {
                      widget.leagueOrTournament.shortDescription = value;
                    },
                  ),
                ),
                new EnsureVisibleWhenFocused(
                  focusNode: _focusNodeLongDescription,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      icon: const Icon(CommunityIcons.text),
                      hintText: Messages.of(context).longDescriptionHint,
                      labelText: Messages.of(context).longDescription,
                    ),
                    keyboardType: TextInputType.multiline,
                    focusNode: _focusNodeLongDescription,
                    obscureText: false,
                    maxLines: 5,
                    initialValue: widget.leagueOrTournament.longDescription,
                    onSaved: (String value) {
                      widget.leagueOrTournament.longDescription = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
