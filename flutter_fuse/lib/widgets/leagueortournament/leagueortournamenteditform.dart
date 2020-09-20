import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../form/genderformfield.dart';
import '../form/sportformfield.dart';
import '../util/communityicons.dart';
import '../util/ensurevisiblewhenfocused.dart';
import '../util/leagueimage.dart';

///
/// Edit the league or tournament,
///
class LeagueOrTournamentEditForm extends StatefulWidget {
  /// Constructor.
  LeagueOrTournamentEditForm(
      {@required this.leagueOrTournament,
      @required GlobalKey<LeagueOrTournamentEditFormState> key})
      : assert(leagueOrTournament != null),
        super(key: key);

  /// The league or tournment to edit,
  final LeagueOrTournament leagueOrTournament;

  @override
  LeagueOrTournamentEditFormState createState() {
    return LeagueOrTournamentEditFormState();
  }
}

///
/// The league or tournament edit state.
///
class LeagueOrTournamentEditFormState
    extends State<LeagueOrTournamentEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeShortDescription = FocusNode();
  final FocusNode _focusNodeLongDescription = FocusNode();
  bool _changedImage = false;
  File _imageFile;
  LeagueOrTournamentBuilder _builder;

  @override
  void initState() {
    super.initState();
    _builder = widget.leagueOrTournament.toBuilder();
  }

  /// Save the form.
  void save() {
    _formKey.currentState.save();
  }

  /// Validate the formn.
  bool validate() {
    if (_formKey.currentState == null) {
      return false;
    }
    return _formKey.currentState.validate();
  }

  void _selectImage() async {
    var imgFile = await ImagePicker.pickImage(
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

  /// The final file to save, null if not changed.
  File get imageFile {
    if (_changedImage) {
      return _imageFile;
    }
    return null;
  }

  ///
  /// The final result to save out.
  ///
  LeagueOrTournamentBuilder get finalLeagueOrTournamentResult {
    if (!_formKey.currentState.validate()) {
      _autovalidate = true;
      return null;
    } else {
      _formKey.currentState.save();
      // Add the date time and the time together.
      return _builder;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return // Show the divisons in the current season.
        Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: SingleLeagueOrTournamentProvider(
          leagueUid: widget.leagueOrTournament.uid,
          builder: (context, leagueBloc) => BlocListener(
            cubit: leagueBloc,
            listener: (context, state) {
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
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  autovalidate: _autovalidate,
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
                            validator: (str) =>
                                _validations.validateName(context, str),
                            initialValue: widget.leagueOrTournament.name,
                            onSaved: (value) {
                              _builder.name = value;
                            },
                          ),
                        ),
                        GenderFormField(
                          decoration: InputDecoration(
                            icon: const Icon(CommunityIcons.genderTransgender),
                            hintText: Messages.of(context).needtoselectgender,
                          ),
                          initialValue: widget.leagueOrTournament.gender,
                          onSaved: (g) {
                            _builder.gender = g;
                          },
                        ),
                        SportFormField(
                          decoration: InputDecoration(
                            icon: const Icon(CommunityIcons.basketball),
                          ),
                          initialValue: widget.leagueOrTournament.sport,
                          onSaved: (s) {
                            _builder.sport = s;
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
                            onSaved: (value) {
                              _builder.shortDescription = value;
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
                            onSaved: (value) {
                              _builder.longDescription = value;
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
