import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';

class AddGameScreen extends StatefulWidget {
  String gameuid;

  AddGameScreen();

  @override
  AddGameScreenState createState() {
    return new AddGameScreenState();
  }
}

class AddGameScreenState extends State<AddGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<EditGameFormState> _gameFormKey =
      new GlobalKey<EditGameFormState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  int currentStep = 0;

  AddGameScreenState() {}

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new EditGameForm(new Game.newGame(EventType.Game), _gameFormKey);
  }

  bool _leaveCurrentState(bool backwards) {
    switch (currentStep) {
      // Check to make sure a team is picked.
      case 0:
        if (_gameFormKey.currentState.game.teamUid == null) {
          print('teamuid ${_gameFormKey.currentState.game.teamUid}');
          teamStepState = StepState.error;
          return false;
        }
        teamStepState = StepState.complete;
        detailsStepState = StepState.editing;
        break;
      // Verify the form is correct.
      case 1:
        if (backwards) {
          // Can always leave this step.
          detailsStepState = StepState.editing;
          return true;
        }
        if (!_gameFormKey.currentState.validate()) {
          detailsStepState = StepState.error;
          createStepStage = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _gameFormKey.currentState.autovalidate = true;
          return false;
        }
        _gameFormKey.currentState.save();
        detailsStepState = StepState.complete;
        createStepStage = StepState.complete;
        break;
      case 2:
        createStepStage = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        currentStep++;
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
    _gameFormKey.currentState.setTeam(str);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
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
                    title: new Text(Messages.of(context).teamselect),
                    state: teamStepState,
                    isActive: true,
                    content: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[new TeamPicker(this._teamChanged)],
                    )),
                new Step(
                    title: const Text('Setup team'),
                    state: detailsStepState,
                    isActive: _gameFormKey.currentState.game.teamUid != '' &&
                        _gameFormKey.currentState.game.teamUid != null,
                    content: this._buildForm(context)),
                new Step(
                    title: const Text('Create'),
                    state: createStepStage,
                    isActive: _gameFormKey.currentState != null &&
                        _gameFormKey.currentState.validate(),
                    content: new Text('Stuff'))
              ],
            )));
  }
}
