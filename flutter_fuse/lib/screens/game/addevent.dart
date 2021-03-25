import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/teams/clubselection.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';
import 'package:clock/clock.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/games/eventeditform.dart';
import '../../widgets/teams/teamselection.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add screen to event to the game
///
class AddEventScreen extends StatefulWidget {
  /// Optional teamUid to use for the add game
  final String teamUid;

  /// Optional seasonUid to use for the add game.
  final String seasonUid;

  /// Create the add event screen.
  AddEventScreen({this.teamUid, this.seasonUid});

  @override
  _AddEventScreenState createState() {
    return _AddEventScreenState();
  }
}

class _AddEventScreenState extends State<AddEventScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<EventEditFormState> _eventFormKey =
      GlobalKey<EventEditFormState>();
  StepState _teamStepState = StepState.editing;
  StepState _timePlaceStepState = StepState.disabled;
  StepState _createStepState = StepState.disabled;
  StepState _clubStepState = StepState.disabled;
  Team _team;
  Game _initGame;
  Club _club;
  int _currentStep = 0;
  AddGameBloc _addGameBloc;
  bool _clubEnabled = false;

  @override
  void initState() {
    newGame();
    super.initState();
    var clubBloc = BlocProvider.of<ClubBloc>(context);
    _addGameBloc = AddGameBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
    if (clubBloc.state.clubs.values.any((club) => club.isAdmin())) {
      _currentStep = 0;
      _clubStepState = StepState.editing;
      _teamStepState = StepState.disabled;
      _clubEnabled = true;
    } else {
      _clubStepState = StepState.complete;
      _teamStepState = StepState.editing;
    }
    if (widget.teamUid != null) {
      _clubStepState = StepState.complete;
      _teamStepState = StepState.complete;
      _timePlaceStepState = StepState.editing;
      _currentStep = 2;
      var teamBloc = BlocProvider.of<TeamBloc>(context);
      _team = teamBloc.state.getTeam(widget.teamUid);
      _teamChanged(_team);
      _initGame = _initGame.rebuild((b) => b..seasonUid = widget.seasonUid);
    }
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return EventEditForm(
      game: _initGame,
      key: _eventFormKey,
    );
  }

  Widget _buildRepeatSummary() {
    if (_initGame != null) {
      var myGame = _initGame;
      String timeStr;
      if (myGame.sharedData.time != myGame.sharedData.endTime) {
        var start = MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
        var end = MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay.fromDateTime(myGame.sharedData.tzEndTime));
        timeStr = '$start - $end';
      } else {
        timeStr = MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
      }
      var cols = <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).accentColor,
            onPrimary: Colors.white,
          ),
          onPressed: () => _onStepperContinue(context),
          child: Text(Messages.of(context).createNew),
        ),
        ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text(MaterialLocalizations.of(context)
              .formatFullDate(myGame.sharedData.tzTime)),
          subtitle: Text(timeStr),
        ),
        ListTile(
          leading: Icon(Icons.place),
          title: Text(
              myGame.sharedData.place.name ?? Messages.of(context).unknown),
          subtitle: Text(myGame.sharedData.place.address ?? ''),
        ),
      ];

      if (myGame.notes.isNotEmpty) {
        cols.add(
          ListTile(
            leading: Icon(Icons.note),
            title: Text(myGame.notes),
          ),
        );
      }
      if (myGame.uniform.isNotEmpty) {
        cols.add(
          ListTile(
            leading: Icon(MdiIcons.tshirtCrew),
            title: Text(myGame.uniform),
          ),
        );
      }

      return Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cols,
          ),
        ),
      );
    } else {
      return SizedBox(height: 0, width: 0);
    }
  }

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      case 0:
        _teamStepState = StepState.editing;
        _clubStepState = StepState.complete;
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
          _teamStepState = StepState.error;
          return false;
        }
        _teamStepState = StepState.complete;
        _timePlaceStepState = StepState.editing;
        break;
      // Verify the form is correct.
      case 2:
        if (backwards) {
          // Can always leave this step.
          _timePlaceStepState = StepState.editing;
          return true;
        }
        if (!_eventFormKey.currentState.validate()) {
          _timePlaceStepState = StepState.error;
          _createStepState = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _eventFormKey.currentState.autoValidate = true;
          return false;
        }
        _eventFormKey.currentState.save();
        _initGame = _eventFormKey.currentState.finalGameResult.build();
        _timePlaceStepState = StepState.complete;
        _createStepState = StepState.editing;
        break;

      case 4:
        _createStepState = StepState.disabled;
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
          _addGameBloc.add(AddGameEventCommit(newGame: _initGame));
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

  void newGame() {
    if (_team != null) {
      final baseTimeDate = clock.now().add(const Duration(days: 1));

      final start = DateTime(
        baseTimeDate.year,
        baseTimeDate.month,
        baseTimeDate.day,
        12,
        0,
      );

      final sharedGameData = GameSharedData((b) => b
        ..uid = ''
        ..type = EventType.Event
        ..time = start
        ..endTime = start.add(const Duration(hours: 1))
        ..timezone = local.name
        ..officialResult.homeTeamLeagueUid = _team.uid);

      final result = GameResultDetailsBuilder()
        ..result = GameResult.Unknown
        ..inProgress = GameInProgress.NotStarted;

      _initGame = Game((b) => b
        ..teamUid = _team.uid
        ..sharedDataUid = ''
        ..sharedData = sharedGameData.toBuilder()
        ..uniform = ''
        ..uid = ''
        ..teamUid = _team.uid
        ..seasonUid = _team.currentSeason
        ..trackAttendance = _team.trackAttendanceInternal
        ..arrivalTime =
            start.subtract(Duration(minutes: _team.arriveEarlyInternal.toInt()))
        ..result = result
        ..notes = '');
    }
  }

  void _clubChanged(Club club) {
    setState((() {
      _club = club;
    }));
  }

  void _teamChanged(Team team) {
    _team = team;
    var start = clock.now().add(const Duration(days: 0));
    if (_initGame == null) {
      newGame();
    }

    setState(() {
      _initGame = _initGame.rebuild((b) => b
        ..teamUid = team.uid
        ..sharedData.time = start.toUtc()
        ..sharedData.endTime = _initGame.sharedData.time
        ..seasonUid = team.currentSeason
        ..trackAttendance = team.trackAttendanceInternal);
    });
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return BlocProvider(
      create: (context) => _addGameBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(messages.title),
        ),
        body: BlocListener(
          bloc: _addGameBloc,
          listener: (context, state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Error saving the event'),
                  );
                },
              );
            }
          },
          child: BlocBuilder(
            bloc: _addGameBloc,
            builder: (context, state) => SavingOverlay(
              saving: state is AddItemSaving,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: StepperAlwaysVisible(
                  lastAsDone: true,
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
                      isActive: _clubEnabled,
                      content: Column(
                        children: [
                          ClubSelection(
                            onChanged: _clubChanged,
                            initialClub: _club,
                          ),
                          ButtonBar(
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _currentStep++),
                                child: Text(Messages.of(context).skipButton),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Step(
                      title: Text(messages.team),
                      state: _teamStepState,
                      isActive: true,
                      content: TeamSelection(
                        club: _club,
                        onChanged: _teamChanged,
                        initialTeam: _team,
                      ),
                    ),
                    Step(
                      title: Text(messages.details),
                      state: _timePlaceStepState,
                      isActive:
                          _team != null && ((_team?.uid?.isNotEmpty) ?? false),
                      content: _buildForm(context),
                    ),
                    Step(
                      title: Text(messages.create),
                      state: _createStepState,
                      isActive: _eventFormKey != null &&
                          _eventFormKey.currentState != null &&
                          _eventFormKey.currentState.validate(),
                      content: _buildRepeatSummary(),
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
