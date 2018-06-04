import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';
import 'package:flutter_fuse/widgets/games/gamedetails.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

class AddGameScreen extends StatefulWidget {
  AddGameScreen();

  @override
  AddGameScreenState createState() {
    return new AddGameScreenState();
  }
}

class AddGameScreenState extends State<AddGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<GameEditFormState> _gameFormKey =
      new GlobalKey<GameEditFormState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  String _teamUid;
  int currentStep = 0;
  Game _initGame;
  bool _saving = false;

  AddGameScreenState();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new GameEditForm(game: _initGame, key: _gameFormKey);
  }

  Widget _buildSummary(BuildContext context) {
    return new GameDetails(
      _initGame,
      adding: true,
    );
  }

  bool _leaveCurrentState(bool backwards) {
    switch (currentStep) {
      // Check to make sure a team is picked.
      case 0:
        if (_teamUid == null) {
          print('teamuid ${_gameFormKey.currentState.widget.game.teamUid}');
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
          _showInSnackBar(Messages.of(context).formerror);
          _gameFormKey.currentState.autovalidate = true;
          return false;
        }
        _gameFormKey.currentState.save();
        _initGame = _gameFormKey.currentState.finalGameResult;
        print('Saved game $_initGame');
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
        if (currentStep < 2) {
          currentStep++;
        } else {
          // Write the game out.
          setState(() {
            _saving = true;
          });
          _initGame.updateFirestore().then((void h) {
            _saving = false;
            Navigator.pop(context);
          }).catchError((Error e) {
            _saving = false;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text("Error"),
                    content: new Text("Error saving the game"),
                  );
                });
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
    _initGame = new Game.newGame(EventType.Game);
    Team teamData = UserDatabaseData.instance.teams[_teamUid];
    DateTime start = new DateTime.now().add(const Duration(days: 1));
    _initGame.time = start.millisecondsSinceEpoch;
    _initGame.arriveTime = start
        .subtract(new Duration(minutes: teamData.arriveEarly))
        .millisecondsSinceEpoch;
    _initGame.endTime = _initGame.time;
    _initGame.teamUid = _teamUid;
    _initGame.seasonUid = teamData.currentSeason;
    _initGame.opponentUid = null;
    _initGame.homegame = false;
    _initGame.uniform = '';
    _initGame.notes = '';
    _initGame.trackAttendance = teamData.trackAttendence;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.title),
      ),
      body: new SavingOverlay(
        saving: _saving,
        child: new Container(
          padding: new EdgeInsets.all(5.0),
          child: new StepperAlwaysVisible(
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
                title: new Text(messages.teamselect),
                state: teamStepState,
                isActive: true,
                content: new DropdownButtonHideUnderline(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new TeamPicker(
                        onChanged: this._teamChanged,
                        teamUid: _teamUid,
                      ),
                    ],
                  ),
                ),
              ),
              new Step(
                title: new Text(messages.gamedetails),
                state: detailsStepState,
                isActive: _teamUid != null && _teamUid.isNotEmpty,
                content: this._buildForm(context),
              ),
              new Step(
                title: new Text(messages.gamecreate),
                state: createStepStage,
                isActive: _gameFormKey != null &&
                    _gameFormKey.currentState != null &&
                    _gameFormKey.currentState.validate(),
                content: this._buildSummary(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
