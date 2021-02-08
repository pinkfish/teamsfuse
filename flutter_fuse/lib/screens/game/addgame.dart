import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/games/gamedetailsbase.dart';
import '../../widgets/games/gameeditform.dart';
import '../../widgets/teams/clubselection.dart';
import '../../widgets/teams/teamselection.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/stepperalwaysvisible.dart';

///
/// Screen to display when doing a game add sequence.
///
class AddGameScreen extends StatefulWidget {
  @override
  _AddGameScreenState createState() {
    return _AddGameScreenState();
  }
}

class _AddGameScreenState extends State<AddGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<GameEditFormState> _gameFormKey =
      GlobalKey<GameEditFormState>();
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
    var clubBloc = BlocProvider.of<ClubBloc>(context);
    if (clubBloc.state.clubs.values.any((club) => club.isAdmin())) {
      _currentStep = 0;
      clubStepState = StepState.editing;
      teamStepState = StepState.disabled;
    }
    super.initState();
    addGameBloc = AddGameBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return GameEditForm(game: _initGame, key: _gameFormKey);
  }

  Widget _buildSummary(BuildContext context) {
    print("Build summary");
    return Column(
      children: [
        GameDetailsBase(
          game: _initGame,
          adding: true,
        ),
        ButtonBar(
          children: [
            TextButton.icon(
              icon: Icon(Icons.save),
              label: Text(Messages.of(context).saveButtonText),
              onPressed: () =>
                  addGameBloc.add(AddGameEventCommit(newGame: _initGame)),
            ),
          ],
        ),
      ],
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
          var clubBloc = BlocProvider.of<ClubBloc>(context);
          if (clubBloc.state.clubs.values.any((club) => club.isAdmin())) {
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
        createStepStage = StepState.disabled;
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
        detailsStepState = StepState.complete;
        createStepStage = StepState.editing;
        break;
      case 3:
        createStepStage = StepState.editing;
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
    setState(() => _team = team);
    var sharedGameData = GameSharedDataBuilder()
      ..uid = ""
      ..timezone = tz.local.name
      ..officialResult.homeTeamLeagueUid = team.uid
      ..type = EventType.Game;
    var start = DateTime.now().add(const Duration(days: 1));
    var result = GameResultDetailsBuilder()
      ..result = GameResult.Unknown
      ..inProgress = GameInProgress.NotStarted;
    _initGame = Game((b) => b
      ..sharedDataUid = ""
      ..uid = ""
      ..teamUid = team.uid
      ..sharedData = sharedGameData
      ..sharedData.time = start.toUtc()
      ..arrivalTime =
          start.subtract(Duration(minutes: team.arriveEarlyInternal.toInt()))
      ..sharedData.endTime = start.toUtc()
      ..seasonUid = team.currentSeason
      ..uniform = ""
      ..notes = ""
      ..result = result
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
    var messages = Messages.of(context);

    return BlocProvider(
      create: (context) => addGameBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(messages.title),
        ),
        body: BlocListener(
          cubit: addGameBloc,
          listener: (context, state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              _showInSnackBar("Error saving the game");
            }
          },
          child: BlocBuilder(
            cubit: addGameBloc,
            builder: (context, state) => SavingOverlay(
              saving: state is AddItemSaving,
              child: Container(
                padding: EdgeInsets.all(5.0),
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
                      state: clubStepState,
                      isActive: false,
                      content: ClubSelection(
                        onChanged: _clubChanged,
                        initialClub: _club,
                      ),
                    ),
                    Step(
                      title: Text(messages.team),
                      state: teamStepState,
                      isActive: true,
                      content: TeamSelection(
                        onChanged: _teamChanged,
                        initialTeam: _team,
                        club: _club,
                      ),
                    ),
                    Step(
                      title: Text(messages.details),
                      state: detailsStepState,
                      isActive: _team != null,
                      content: _buildForm(context),
                    ),
                    Step(
                      title: Text(messages.create),
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
