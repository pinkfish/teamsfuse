import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamedetailsbase.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';
import 'package:flutter_fuse/widgets/teams/clubselection.dart';
import 'package:flutter_fuse/widgets/teams/teamselection.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

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
  AddGameScreenState();

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
  AddGameBloc addGameBloc;

  @override
  void initState() {
    ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);
    if (clubBloc.state.clubs.values.any((Club club) => club.isAdmin())) {
      _currentStep = 0;
      clubStepState = StepState.editing;
      teamStepState = StepState.disabled;
    }
    super.initState();
    addGameBloc = new AddGameBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new GameEditForm(game: _initGame, key: _gameFormKey);
  }

  Widget _buildSummary(BuildContext context) {
    return new GameDetailsBase(
      game: _initGame,
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
          ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);
          if (clubBloc.state.clubs.values.any((Club club) => club.isAdmin())) {
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
        _initGame = _gameFormKey.currentState.finalGameResult.build();
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
          addGameBloc.add(AddGameEventCommit(newGame: _initGame));
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
    GameSharedDataBuilder sharedGameData = GameSharedDataBuilder()
      ..officialResult.homeTeamLeagueUid = team.uid
      ..type = EventType.Game;
    DateTime start = new DateTime.now().add(const Duration(days: 1));
    _initGame = new Game((b) => b
      ..teamUid = team.uid
      ..sharedData = sharedGameData
      ..sharedData.time = start.millisecondsSinceEpoch
      ..arriveTime = start
          .subtract(new Duration(minutes: team.arriveEarlyInternal.toInt()))
          .millisecondsSinceEpoch
      ..sharedData.endTime = start.millisecondsSinceEpoch
      ..seasonUid = team.currentSeason
      ..uniform = ""
      ..notes = ""
      ..trackAttendance = team.trackAttendenceInternal);
    setState(() {});
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
    return BlocProvider(
      create: (BuildContext context) => addGameBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(messages.title),
        ),
        body: BlocListener(
          cubit: addGameBloc,
          listener: (BuildContext context, AddItemState state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text("Error"),
                    content: new Text("Error saving the game"),
                  );
                },
              );
            }
          },
          child: BlocBuilder(
            cubit: addGameBloc,
            builder: (BuildContext context, AddItemState state) =>
                SavingOverlay(
              saving: state is AddItemSaving,
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
          ),
        ),
      ),
    );
  }
}
