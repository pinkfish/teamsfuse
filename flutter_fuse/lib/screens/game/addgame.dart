import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/teams/clubselection.dart';
import 'package:flutter_fuse/widgets/teams/teamselection.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';
import 'package:flutter_fuse/widgets/games/gamedetails.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

///
/// Screen to display when doing a game add sequence.
///
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
  StepState clubStepState = StepState.disabled;
  Team _team;
  Club _club;
  int _currentStep = 1;
  Game _initGame;
  bool _saving = false;

  AddGameScreenState();

  @override
  void initState() {
    if (UserDatabaseData.instance.clubs.values
        .any((Club club) => club.isAdmin())) {
      _currentStep = 0;
      clubStepState = StepState.editing;
      teamStepState = StepState.disabled;
    }
    super.initState();
  }

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
    switch (_currentStep) {
      case 0:
        teamStepState = StepState.editing;
        clubStepState = StepState.complete;
        break;
      // Check to make sure a team is picked.
      case 1:
        if (backwards) {
          if (UserDatabaseData.instance.clubs.values
              .any((Club club) => club.isAdmin())) {
            return true;
          }
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        if (_team == null) {
          teamStepState = StepState.error;
          return false;
        }
        teamStepState = StepState.complete;
        detailsStepState = StepState.editing;
        break;
      // Verify the form is correct.
      case 2:
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
      case 3:
        createStepStage = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        } else {
          // Write the game out.
          setState(() {
            //_saving = true;
          });
          _initGame.updateFirestore(true).then((void h) {
            _saving = false;
            Navigator.pop(context);
          }).catchError((Error e) {
            _saving = false;
            showDialog<bool>(
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
    if (_leaveCurrentState(step < _currentStep)) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  void _teamChanged(Team team) {
    print('Team $team');
    //_gameFormKey.currentState.setTeam(str);
    GameSharedData sharedGameData = new GameSharedData(type: EventType.Game);
    _initGame = new Game(sharedData: sharedGameData);
    DateTime start = new DateTime.now().add(const Duration(days: 1));
    _initGame.sharedData.time = start.millisecondsSinceEpoch;
    _initGame.arriveTime = start
        .subtract(new Duration(minutes: team.arriveEarly.toInt()))
        .millisecondsSinceEpoch;
    _initGame.sharedData.endTime = _initGame.sharedData.time;
    _initGame.teamUid = team.uid;
    _initGame.seasonUid = team.currentSeason;
    _initGame.opponentUids = <String>[];
    _initGame.homegame = false;
    _initGame.uniform = '';
    _initGame.notes = '';
    _initGame.trackAttendance = team.trackAttendence;
    setState(() {
      _team = team;
    });
  }

  void _clubChanged(Club club) {
    setState((() {
      _club = club;
    }));
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    print(_team);
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
                state: clubStepState,
                isActive: false,
                content: new ClubSelection(
                  onChanged: _clubChanged,
                  initialClub: _club,
                ),
              ),
              new Step(
                title: new Text(messages.team),
                state: teamStepState,
                isActive: true,
                content: new TeamSelection(
                  onChanged: _teamChanged,
                  initialTeam: _team,
                  club: _club,
                ),
              ),
              new Step(
                title: new Text(messages.details),
                state: detailsStepState,
                isActive: _team != null,
                content: _buildForm(context),
              ),
              new Step(
                title: new Text(messages.create),
                state: createStepStage,
                isActive: _gameFormKey != null &&
                    _gameFormKey.currentState != null &&
                    _gameFormKey.currentState.validate(),
                content: _buildSummary(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
