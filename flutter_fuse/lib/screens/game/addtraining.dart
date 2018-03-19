import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/games/trainingeditform.dart';
import 'package:flutter_fuse/widgets/games/repeatdetails.dart';
import 'package:timezone/timezone.dart';

class AddTrainingScreen extends StatefulWidget {
  AddTrainingScreen();

  @override
  AddTrainingScreenState createState() {
    return new AddTrainingScreenState();
  }
}

class AddTrainingScreenState extends State<AddTrainingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<TrainingEditFormState> _trainingFormKey =
      new GlobalKey<TrainingEditFormState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState repeatStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  String _teamUid;
  Game _initGame;
  int currentStep = 0;

  AddTrainingScreenState();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new TrainingEditForm(
        game: _initGame, key: _trainingFormKey);
  }

  Widget _buildRepeat(BuildContext context) {
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(_initGame.time);
    return new RepeatDetailsWidget(time.weekday);
  }

  bool _leaveCurrentState(bool backwards) {
    switch (currentStep) {
      // Check to make sure a team is picked.
      case 0:
        if (_teamUid == null) {
          teamStepState = StepState.error;
          return false;
        }
        teamStepState = StepState.complete;
        detailsStepState = StepState.editing;
        repeatStepState = StepState.disabled;
        break;
      // Verify the form is correct.
      case 1:
        if (backwards) {
          // Can always leave this step.
          detailsStepState = StepState.editing;
          return true;
        }
        if (!_trainingFormKey.currentState.validate()) {
          detailsStepState = StepState.error;
          createStepStage = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _trainingFormKey.currentState.autoValidate = true;
          repeatStepState = StepState.disabled;
          return false;
        }
        _trainingFormKey.currentState.save();
        detailsStepState = StepState.complete;
        repeatStepState = StepState.editing;
        break;
       case 2:
        repeatStepState = StepState.complete;
        createStepStage = StepState.complete;
        break;
      case 3:
        createStepStage = StepState.disabled;
        repeatStepState = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (currentStep < 3) {
          currentStep++;
        } else {
          // Write the game out.
          _trainingFormKey.currentState
              .validateAndSaveToFirebase()
              .then((bool result) {
            if (result) {
              Navigator.pop(context);
            }
          });
        }
      });
    }
  }

  void _onStepTapped(int step) {
    if (_leaveCurrentState(step < currentStep)) {
      setState(() {
        currentStep = step;
      });
    }
  }

  void _teamChanged(String str) {
    _teamUid = str;
    //_gameFormKey.currentState.setTeam(str);
    _initGame = new Game.newGame(EventType.Practice);
    Team teamData = UserDatabaseData.instance.teams[_teamUid];
    DateTime start = new DateTime.now().add(const Duration(days: 0));
    _initGame.time = start.millisecondsSinceEpoch;
    _initGame.arriveEarly = start
        .subtract(new Duration(minutes: teamData.arriveEarly))
        .millisecondsSinceEpoch;
    _initGame.teamUid = _teamUid;
    _initGame.seasonUid = teamData.currentSeason;
    _initGame.opponentUid = null;
    _initGame.homegame = false;
    _initGame.uniform = '';
    _initGame.notes = '';
    // Set the timezone to the local timezone to start with.
    //_initGame.timezone = getLocation(start.timeZoneName).name;
print('team changed ${_initGame.toJSON()}');
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.title),
      ),
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        child: new Stepper(
          type: StepperType.horizontal,
          currentStep: this.currentStep,
          onStepContinue: () {
            this._onStepperContinue(context);
          },
          onStepCancel: () {
            // Go back
            Navigator.of(context).pop();
          },
          onStepTapped: (int step) {
            this._onStepTapped(step);
          },
          steps: <Step>[
            new Step(
              title: new Text(messages.team),
              state: teamStepState,
              isActive: true,
              content: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new TeamPicker(this._teamChanged),
                ],
              ),
            ),
            new Step(
              title: new Text(messages.gamedetails),
              state: detailsStepState,
              isActive: _teamUid != null && _teamUid.isNotEmpty,
              content: this._buildForm(context),
            ),
            new Step(
              title: new Text(messages.repeat),
              state: repeatStepState,
              isActive: _teamUid != null && _teamUid.isNotEmpty,
              content: this._buildRepeat(context),
            ),
            new Step(
              title: new Text(messages.gamecreate),
              state: createStepStage,
              isActive: _trainingFormKey != null &&
                  _trainingFormKey.currentState != null &&
                  _trainingFormKey.currentState.validate(),
              content: new Text('Stuff'),
            )
          ],
        ),
      ),
    );
  }
}
