import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleclubprovider.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/clubs/clubimage.dart';
import '../../widgets/form/clubpicker.dart';
import '../../widgets/form/playerformfield.dart';
import '../../widgets/player/gendericon.dart';
import '../../widgets/teams/teameditform.dart';
import '../../widgets/teams/teamimage.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/stepperalwaysvisible.dart';

///
/// Adds a team to the specific club.
///
class AddTeamScreen extends StatefulWidget {
  /// Constructor.
  AddTeamScreen({this.clubUid});

  /// The club to add the team too.
  final String clubUid;

  @override
  _AddTeamScreenState createState() {
    return _AddTeamScreenState();
  }
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final GlobalKey<TeamEditFormState> _formKeyTeam =
      GlobalKey<TeamEditFormState>();
  final GlobalKey<FormState> _formKeyPlayer = GlobalKey<FormState>();
  int _currentStep;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StepState _detailsStepState = StepState.disabled;
  StepState _detailsSecondStepState = StepState.disabled;
  StepState _createStepStage = StepState.disabled;
  StepState _clubStepState = StepState.disabled;
  StepState _playerStepState = StepState.editing;
  Uint8List _imageFileToAdd;
  String _clubUid = ClubPicker.noClub;
  String _playerUid;
  TeamBuilder _teamToAdd;
  AddTeamBloc _addTeamBloc;

  @override
  void initState() {
    super.initState();
    _addTeamBloc = AddTeamBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
    if (isActiveClub()) {
      _currentStep = 0;
      _detailsStepState = StepState.disabled;
      _clubStepState = StepState.editing;
      if (widget.clubUid != null) {
        _clubUid = widget.clubUid;
        _currentStep = 1;
        _clubStepState = StepState.complete;
        _detailsStepState = StepState.editing;
      }
    } else {
      _currentStep = 1;
      _clubStepState = StepState.disabled;
      _detailsStepState = StepState.editing;
    }
    _teamToAdd = TeamBuilder();
    _teamToAdd.name = '';
    _teamToAdd.arriveEarlyInternal = 0;
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed() async {
    if (_teamToAdd != null) {
      if (_clubUid != ClubPicker.noClub) {
        _teamToAdd.clubUid = _clubUid;
      }
      _addTeamBloc.add(AddTeamEventCommit(
        seasonName: _teamToAdd.currentSeason,
        team: _teamToAdd,
        playerUid: _playerUid,
        teamImage: _imageFileToAdd,
      ));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  String _seasonName() {
    if (_teamToAdd.currentSeason != null &&
        _teamToAdd.currentSeason.isNotEmpty) {
      return _teamToAdd.currentSeason;
    }
    return Messages.of(context).noseasons;
  }

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      case 0:
        _clubStepState = StepState.complete;
        _detailsStepState = StepState.editing;
        break;
      case 1:
        if (backwards) {
          // Can always leave this step.
          _detailsStepState = StepState.editing;
          return true;
        }
        // Verify a player has been picked.
        _formKeyPlayer.currentState.save();
        if (_playerUid == PlayerFormField.nonePlayer) {
          _playerStepState = StepState.error;
          _detailsStepState = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _playerStepState = StepState.complete;
        _detailsStepState = StepState.editing;
        return true;
      // Check to make sure a team is picked.
      case 2:
        // Verify the form is correct.
        if (backwards) {
          // Can always leave this step.
          _detailsStepState = StepState.editing;
          return true;
        }
        if (!_formKeyTeam.currentState.validate()) {
          _detailsStepState = StepState.error;
          _detailsSecondStepState = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _teamToAdd = _formKeyTeam.currentState.validateAndCreate();
        if (_teamToAdd == null) {
          _detailsStepState = StepState.error;
          _detailsSecondStepState = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _imageFileToAdd = _formKeyTeam.currentState.getImageFile();
        _detailsStepState = StepState.complete;
        _detailsSecondStepState = StepState.editing;
        break;
      // Check to make sure a team is picked.
      case 3:
        // Verify the form is correct.
        if (backwards) {
          // Can always leave this step.
          _detailsSecondStepState = StepState.editing;
          return true;
        }
        if (!_formKeyTeam.currentState.validate()) {
          _detailsSecondStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _teamToAdd = _formKeyTeam.currentState.validateAndCreate();
        if (_teamToAdd == null) {
          _detailsSecondStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _imageFileToAdd = _formKeyTeam.currentState.getImageFile();
        _detailsSecondStepState = StepState.complete;
        _createStepStage = StepState.editing;
        break;
      case 4:
        _createStepStage = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (_currentStep < 4) {
          _currentStep++;
        } else {
          // Write the game out.
          _savePressed();
        }
      });
    }
  }

  void _onStepTapped(int step) {
    if (step == 0 && !isActiveClub()) {
      _showInSnackBar(Messages.of(context).noclub);
      return;
    }
    if (_leaveCurrentState(step < _currentStep)) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  Widget _buildImage() {
    if (_imageFileToAdd == null) {
      return Icon(Icons.upload_file, size: 100);
    }
    return TeamImage(teamImage: _imageFileToAdd);
  }

  bool isActiveClub() {
    var clubBloc = BlocProvider.of<ClubBloc>(context);

    // Only true if they are member of a club of some sort.
    return clubBloc.state.clubs.values.any((c) => c.isAdmin());
  }

  Widget _buildSummary() {
    if (_currentStep == 4) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildImage(),
            ListTile(
              leading: const Icon(Icons.title),
              subtitle: RichText(
                text: TextSpan(
                  text: _teamToAdd.currentSeason,
                  children: <TextSpan>[
                    TextSpan(
                      text: Messages.of(context).sportName(_teamToAdd.sport),
                    ),
                  ],
                ),
              ),
              title: Text(_teamToAdd.name),
              trailing: GenderIcon(_teamToAdd.gender),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_seasonName()),
            ),
            _clubUid == ClubPicker.noClub
                ? SizedBox(height: 0)
                : SingleClubProvider(
                    clubUid: _clubUid,
                    builder: (context, singleClubBloc) => BlocBuilder(
                      cubit: singleClubBloc,
                      builder: (context, clubState) {
                        ListTile(
                          leading: const Icon(MdiIcons.group),
                          title: _clubUid != ClubPicker.noClub
                              ? Text(singleClubBloc.state.club.name)
                              : Text(Messages.of(context).noclub),
                          trailing: _clubUid != ClubPicker.noClub
                              ? ClubImage(
                                  clubUid: _clubUid,
                                  width: 20.0,
                                  height: 20.0,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
            ListTile(
              leading: const Icon(MdiIcons.tshirtCrew),
              title: Text(_teamToAdd.league.isEmpty
                  ? Messages.of(context).noleagues
                  : _teamToAdd.league),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: Text(Messages.of(context)
                  .arrivebefore(_teamToAdd.arriveEarlyInternal.toInt())),
            ),
            ListTile(
              leading: const Icon(MdiIcons.trafficLight),
              title: Text(Messages.of(context).trackattendence(
                  _teamToAdd.trackAttendenceInternal
                      ? Tristate.Yes
                      : Tristate.No)),
            )
          ],
        ),
      );
    } else {
      return SizedBox(height: 0);
    }
  }

  Widget _teamEditForm(StartSection section) {
    if (_clubUid != ClubPicker.noClub) {
      return SingleClubProvider(
        clubUid: _clubUid,
        builder: (context, singleClubBloc) => BlocBuilder(
            cubit: singleClubBloc,
            builder: (context, singleClubState) {
              if (singleClubState is SingleClubDeleted) {
                return DeletedWidget();
              }
              if (singleClubState is SingleClubUninitialized) {
                return LoadingWidget();
              }
              return TeamEditForm(
                _teamToAdd,
                singleClubState.club,
                _formKeyTeam,
                startSection: section,
              );
            }),
      );
    } else {
      return TeamEditForm(
        _teamToAdd,
        null,
        _formKeyTeam,
        startSection: section,
      );
    }
  }

  Widget _buildBody() {
    var messages = Messages.of(context);
    return BlocProvider(
      create: (contex) => _addTeamBloc,
      child: BlocListener(
        cubit: _addTeamBloc,
        listener: (context, addState) {
          if (addState is AddItemDone) {
            Navigator.pop(context);
          }
          if (addState is AddItemSaveFailed) {
            _showInSnackBar(Messages.of(context).formerror);
          }
        },
        child: BlocBuilder(
          cubit: _addTeamBloc,
          builder: (context, addState) => SavingOverlay(
            saving: addState is AddItemSaving,
            child: StepperAlwaysVisible(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: () {
                _onStepperContinue(context);
              },
              onStepCancel: () {
                // Go back
                Navigator.of(context).pop();
              },
              onStepTapped: (step) {
                _onStepTapped(step);
              },
              steps: <Step>[
                Step(
                  title: Text(messages.club),
                  state: _clubStepState,
                  isActive: isActiveClub() && _currentStep >= 0,
                  content: ClubPicker(
                    clubUid: _clubUid,
                    onChanged: (val) => setState(() => _clubUid = val),
                  ),
                ),
                Step(
                  title: Text(messages.player),
                  state: _playerStepState,
                  isActive: _currentStep >= 1,
                  content: Form(
                    key: _formKeyPlayer,
                    child: PlayerFormField(
                      initialValue: PlayerFormField.nonePlayer,
                      onSaved: (player) => _playerUid = player,
                    ),
                  ),
                ),
                Step(
                  title: Text(messages.team),
                  state: _detailsStepState,
                  isActive: _currentStep >= 2,
                  content: SingleChildScrollView(
                    child: _teamEditForm(StartSection.start),
                  ),
                ),
                Step(
                  title: Text(messages.details),
                  state: _detailsSecondStepState,
                  isActive: _currentStep >= 3,
                  content: SingleChildScrollView(
                    child: _teamEditForm(
                      StartSection.end,
                    ),
                  ),
                ),
                Step(
                  title: Text(messages.create),
                  state: _createStepStage,
                  isActive: _currentStep == 4,
                  content: _buildSummary(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      floatingActionButton: _currentStep == 4
          ? FloatingActionButton(
              onPressed: _savePressed,
              child: const Icon(Icons.check),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
