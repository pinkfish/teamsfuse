import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/teams/teameditform.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';
import 'package:flutter_fuse/widgets/util/gendericon.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/form/clubpicker.dart';
import 'package:flutter_fuse/widgets/form/playerformfield.dart';
import 'dart:io';

class AddTeamScreen extends StatefulWidget {
  @override
  AddTeamScreenState createState() {
    return new AddTeamScreenState();
  }
}

class AddTeamScreenState extends State<AddTeamScreen> {
  final GlobalKey<TeamEditFormState> _formKeyTeam =
      new GlobalKey<TeamEditFormState>();
  final GlobalKey<FormState> _formKeyPlayer = new GlobalKey<FormState>();
  bool _saving = false;
  int _currentStep;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StepState _detailsStepState = StepState.disabled;
  StepState _createStepStage = StepState.disabled;
  StepState _clubStepState = StepState.disabled;
  StepState _playerStepState = StepState.editing;
  Team _teamToAdd = new Team();
  File _imageFileToAdd;
  String _clubUid;
  String _playerUid;

  @override
  void initState() {
    super.initState();
    if (isActiveClub()) {
      _currentStep = 0;
      _detailsStepState = StepState.disabled;
      _clubStepState = StepState.editing;
    } else {
      _currentStep = 1;
      _clubStepState = StepState.disabled;
      _detailsStepState = StepState.editing;
    }
    _teamToAdd.currentSeason = "";
    _teamToAdd.name = "";
    _teamToAdd.league = "";
    _teamToAdd.arriveEarly = 0;
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    setState(() {
      _saving = true;
    });
    try {
      if (_teamToAdd != null) {
        if (_clubUid != null && _clubUid != ClubPicker.noClub) {
          _teamToAdd.clubUid = _clubUid;
        }
        if (_imageFileToAdd != null) {
          Uri uri = await UserDatabaseData.instance.updateModel
              .updateTeamImage(_teamToAdd, _imageFileToAdd);
          _teamToAdd.photoUrl = uri.toString();
        }
        // Create the season too.
        Season season = _teamToAdd.seasons[_teamToAdd.currentSeason];
        season.players.add(new SeasonPlayer(
          playerUid: _playerUid,
          role: RoleInTeam.Player,
        ));
        await _teamToAdd.updateFirestore();
        await _teamToAdd.seasons[_teamToAdd.currentSeason].updateFirestore(includePlayers: true);
        Navigator.pop(context);
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {
      setState(() {
        _saving = false;
      });
    }
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
          _createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _teamToAdd = _formKeyTeam.currentState.validateAndCreate();
        if (_teamToAdd == null) {
          _detailsStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _imageFileToAdd = _formKeyTeam.currentState.getImageFile();
        _detailsStepState = StepState.complete;
        _createStepStage = StepState.editing;
        break;
      case 3:
        _createStepStage = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (_currentStep < 3) {
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
      return new TeamImage(
        team: _teamToAdd,
      );
    }
    return new Image.file(_imageFileToAdd);
  }

  bool isActiveClub() {
    // Only true if they are member of a club of some sort.
    return UserDatabaseData.instance.clubs.values.any((Club c) => c.isAdmin());
  }

  Widget _buildSummary() {
    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          _buildImage(),
          new ListTile(
            leading: const Icon(Icons.title),
            subtitle: new RichText(
              text: new TextSpan(
                text: _teamToAdd.currentSeason,
                children: <TextSpan>[
                  new TextSpan(
                    text: Messages.of(context).sportname(_teamToAdd.sport),
                  ),
                ],
              ),
            ),
            title: new Text(_teamToAdd.name),
            trailing: new GenderIcon(_teamToAdd.gender),
          ),
          new ListTile(
            leading: const Icon(Icons.calendar_today),
            title: new Text(_teamToAdd.currentSeason),
          ),
          new ListTile(
            leading: const Icon(CommunityIcons.group),
            title: _clubUid != null && _clubUid != ClubPicker.noClub
                ? new Text(
                    UserDatabaseData.instance.clubs[_teamToAdd.clubUid].name)
                : new Text(""),
            trailing: _clubUid != null && _clubUid != ClubPicker.noClub
                ? new ClubImage(
                    clubUid: _clubUid,
                    width: 20.0,
                    height: 20.0,
                  )
                : null,
          ),
          new ListTile(
            leading: const Icon(CommunityIcons.tshirtCrew),
            title: new Text(_teamToAdd.league),
          ),
          new ListTile(
            leading: const Icon(Icons.timer),
            title: new Text(Messages.of(context)
                .arrivebefore(_teamToAdd.arriveEarly.toInt())),
          ),
          new ListTile(
            leading: const Icon(CommunityIcons.trafficLight),
            title: new Text(Messages.of(context).trackattendence(
                _teamToAdd.trackAttendence ? Tristate.Yes : Tristate.No)),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    Messages messages = Messages.of(context);
    return new SavingOverlay(
      saving: _saving,
      child: new Stepper(
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
          new Step(
            title: new Text(messages.club),
            state: _clubStepState,
            isActive: isActiveClub(),
            content: new ClubPicker(
              clubUid: _clubUid,
              onChanged: (String val) => _clubUid = val,
            ),
          ),
          new Step(
            title: new Text(messages.player),
            state: _playerStepState,
            isActive: true,
            content: new Form(
              key: _formKeyPlayer,
              child: new PlayerFormField(
                initialValue: PlayerFormField.nonePlayer,
                onSaved: (String player) => _playerUid = player,
              ),
            ),
          ),
          new Step(
            title: new Text(messages.team),
            state: _detailsStepState,
            isActive: true,
            content: new SingleChildScrollView(
              child: new TeamEditForm(
                _teamToAdd,
                _formKeyTeam,
              ),
            ),
          ),
          new Step(
            title: new Text(messages.create),
            state: _createStepStage,
            isActive: true,
            content: _buildSummary(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      floatingActionButton: _currentStep == 1
          ? new FloatingActionButton(
              onPressed: () => _savePressed(),
              child: const Icon(Icons.check),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
