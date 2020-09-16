import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/genderformfield.dart';
import 'package:flutter_fuse/widgets/form/sportformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/singleleagueortournamentprovider.dart';

// of the game.  Does not have the add game step flow.
class LeagueOrTournamentEditForm extends StatefulWidget {
  LeagueOrTournamentEditForm(
      {@required this.leagueOrTournament,
      @required GlobalKey<LeagueOrTournamentEditFormState> key})
      : super(key: key);

  final LeagueOrTournament leagueOrTournament;

  @override
  LeagueOrTournamentEditFormState createState() {
    return LeagueOrTournamentEditFormState();
  }
}

class LeagueOrTournamentEditFormState
    extends State<LeagueOrTournamentEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool autovalidate = false;
  Validations _validations = Validations();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeShortDescription = FocusNode();
  FocusNode _focusNodeLongDescription = FocusNode();
  bool _changedImage = false;
  File _imageFile;
  LeagueOrTournamentBuilder builder;

  @override
  void initState() {
    super.initState();
    builder = widget.leagueOrTournament.toBuilder();
  }

  void save() {
    _formKey.currentState.save();
  }

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
      return LeagueImage(leagueOrTournament: widget.leagueOrTournament);
    }
    return Image.file(_imageFile);
  }

  File get imageFile {
    if (_changedImage) {
      return _imageFile;
    }
    return null;
  }

  LeagueOrTournamentBuilder get finalLeagueOrTournamentResult {
    if (!_formKey.currentState.validate()) {
      autovalidate = true;
      return null;
    } else {
      _formKey.currentState.save();
      // Add the date time and the time together.
      return builder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return // Show the divisons in the current season.
        Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: SingleLeagueOrTournamentProvider(
          leagueUid: widget.leagueOrTournament.uid,
          builder:
              (BuildContext context, SingleLeagueOrTournamentBloc leagueBloc) =>
                  BlocListener(
            cubit: leagueBloc,
            listener:
                (BuildContext context, SingleLeagueOrTournamentState state) {
              if (state is SingleLeagueOrTournamentDeleted) {
                Navigator.pop(context);
                return;
              }
              if (state is SingleLeagueOrTournamentLoaded) {
                // Tell it to load the seasons.
                leagueBloc.add(SingleLeagueOrTournamentLoadSeasons());
              }
            },
            child: BlocBuilder(
              cubit: leagueBloc,
              builder:
                  (BuildContext context, SingleLeagueOrTournamentState state) {
                return Form(
                  key: _formKey,
                  autovalidate: autovalidate,
                  child: DropdownButtonHideUnderline(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          onPressed: _selectImage,
                          iconSize: (screenSize.width < 500)
                              ? 120.0
                              : (screenSize.width / 4) + 12.0,
                          icon: _buildImage(),
                        ),
                        EnsureVisibleWhenFocused(
                          focusNode: _focusNodeName,
                          child: TextFormField(
                            decoration: InputDecoration(
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
                              builder.name = value;
                            },
                          ),
                        ),
                        GenderFormField(
                          decoration: InputDecoration(
                            icon: const Icon(CommunityIcons.genderTransgender),
                            hintText: Messages.of(context).needtoselectgender,
                          ),
                          initialValue: widget.leagueOrTournament.gender,
                          onSaved: (Gender g) {
                            builder.gender = g;
                          },
                        ),
                        SportFormField(
                          decoration: InputDecoration(
                            icon: const Icon(CommunityIcons.basketball),
                          ),
                          initialValue: widget.leagueOrTournament.sport,
                          onSaved: (Sport s) {
                            builder.sport = s;
                          },
                        ),
                        EnsureVisibleWhenFocused(
                          focusNode: _focusNodeShortDescription,
                          child: TextFormField(
                            decoration: InputDecoration(
                              icon: const Icon(CommunityIcons.textShort),
                              hintText:
                                  Messages.of(context).shortDescriptionHint,
                              labelText: Messages.of(context).shortDescription,
                            ),
                            keyboardType: TextInputType.text,
                            focusNode: _focusNodeShortDescription,
                            obscureText: false,
                            initialValue:
                                widget.leagueOrTournament.shortDescription,
                            onSaved: (String value) {
                              builder.shortDescription = value;
                            },
                          ),
                        ),
                        EnsureVisibleWhenFocused(
                          focusNode: _focusNodeLongDescription,
                          child: TextFormField(
                            decoration: InputDecoration(
                              icon: const Icon(CommunityIcons.text),
                              hintText:
                                  Messages.of(context).longDescriptionHint,
                              labelText: Messages.of(context).longDescription,
                            ),
                            keyboardType: TextInputType.multiline,
                            focusNode: _focusNodeLongDescription,
                            obscureText: false,
                            maxLines: 5,
                            initialValue:
                                widget.leagueOrTournament.longDescription,
                            onSaved: (String value) {
                              builder.longDescription = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
