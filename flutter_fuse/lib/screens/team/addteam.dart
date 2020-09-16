import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/form/clubpicker.dart';
import '../../widgets/form/playerformfield.dart';
import '../../widgets/teams/teameditform.dart';
import '../../widgets/util/clubimage.dart';
import '../../widgets/util/communityicons.dart';
import '../../widgets/util/gendericon.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/stepperalwaysvisible.dart';
import '../../widgets/util/teamimage.dart';

class AddTeamScreen extends StatefulWidget {
  AddTeamScreen({this.clubUid});

  final String clubUid;

  @override
  AddTeamScreenState createState() {
    return AddTeamScreenState();
  }
}

class AddTeamScreenState extends State<AddTeamScreen> {
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
  File _imageFileToAdd;
  String _clubUid;
  String _seasonNameInternal;
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
    _teamToAdd.name = "";
    _teamToAdd.arriveEarlyInternal = 0;
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        ?.showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed() async {
    if (_teamToAdd != null) {
      if (_clubUid != null && _clubUid != ClubPicker.noClub) {
        _teamToAdd.clubUid = _clubUid;
      }
      _addTeamBloc.add(AddTeamEventCommit(
          seasonName: _seasonNameInternal,
          team: _teamToAdd,
          playerUid: _playerUid,
          teamImage: _imageFileToAdd));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  String _seasonName() {
    if (_seasonNameInternal != null && _seasonNameInternal.isNotEmpty) {
      return _seasonNameInternal;
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
      return TeamImage(
        team: _teamToAdd.build(),
      );
    }
    return TeamImage(teamImage: _imageFileToAdd);
  }

  bool isActiveClub() {
    var clubBloc = BlocProvider.of<ClubBloc>(context);

    // Only true if they are member of a club of some sort.
    return clubBloc.state.clubs.values.any((Club c) => c.isAdmin());
  }

  Widget _buildSummary() {
    var clubBloc = BlocProvider.of<ClubBloc>(context);
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
                    text: Messages.of(context).sportname(_teamToAdd.sport),
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
          ListTile(
            leading: const Icon(CommunityIcons.group),
            title: _clubUid != null && _clubUid != ClubPicker.noClub
                ? Text(clubBloc.state.clubs[_clubUid].name)
                : Text(Messages.of(context).noclub),
            trailing: _clubUid != null && _clubUid != ClubPicker.noClub
                ? ClubImage(
                    clubUid: _clubUid,
                    width: 20.0,
                    height: 20.0,
                  )
                : null,
          ),
          ListTile(
            leading: const Icon(CommunityIcons.tshirtCrew),
            title: Text(_teamToAdd.league),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: Text(Messages.of(context)
                .arrivebefore(_teamToAdd.arriveEarlyInternal.toInt())),
          ),
          ListTile(
            leading: const Icon(CommunityIcons.trafficLight),
            title: Text(Messages.of(context).trackattendence(
                _teamToAdd.trackAttendenceInternal
                    ? Tristate.Yes
                    : Tristate.No)),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    Messages messages = Messages.of(context);
    return BlocProvider(
      create: (BuildContext contex) => _addTeamBloc,
      child: BlocListener(
        cubit: _addTeamBloc,
        listener: (BuildContext context, AddItemState addState) {
          if (addState is AddItemDone) {
            Navigator.pop(context);
          }
          if (addState is AddItemSaveFailed) {
            _showInSnackBar(Messages.of(context).formerror);
          }
        },
        child: BlocBuilder(
          cubit: _addTeamBloc,
          builder: (BuildContext context, AddItemState addState) =>
              SavingOverlay(
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
              onStepTapped: (int step) {
                _onStepTapped(step);
              },
              steps: <Step>[
                Step(
                  title: Text(messages.club),
                  state: _clubStepState,
                  isActive: isActiveClub(),
                  content: ClubPicker(
                    clubUid: _clubUid,
                    onChanged: (String val) => setState(() => _clubUid = val),
                  ),
                ),
                Step(
                  title: Text(messages.player),
                  state: _playerStepState,
                  isActive: true,
                  content: Form(
                    key: _formKeyPlayer,
                    child: PlayerFormField(
                      initialValue: PlayerFormField.nonePlayer,
                      onSaved: (String player) => _playerUid = player,
                    ),
                  ),
                ),
                Step(
                  title: Text(messages.team),
                  state: _detailsStepState,
                  isActive: true,
                  content: SingleChildScrollView(
                    child: TeamEditForm(
                      _teamToAdd.build(),
                      _formKeyTeam,
                      startSection: StartSection.start,
                    ),
                  ),
                ),
                Step(
                  title: Text(messages.details),
                  state: _detailsSecondStepState,
                  isActive: true,
                  content: SingleChildScrollView(
                    child: TeamEditForm(
                      _teamToAdd.build(),
                      _formKeyTeam,
                      startSection: StartSection.end,
                    ),
                  ),
                ),
                Step(
                  title: Text(messages.create),
                  state: _createStepStage,
                  isActive: true,
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
              onPressed: () => _savePressed(),
              child: const Icon(Icons.check),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
