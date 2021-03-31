import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/localutilities.dart';
import 'package:flutter_fuse/widgets/teams/clubselection.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/games/repeatdetails.dart';
import '../../widgets/games/trainingeditform.dart';
import '../../widgets/teams/teamselection.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Adds a traning session.
///
class AddTrainingScreen extends StatefulWidget {
  /// Optional teamUid to use for the add game
  final String teamUid;

  /// Optional seasonUid to use for the add game.
  final String seasonUid;

  /// Create the ad training screen.
  AddTrainingScreen({this.teamUid, this.seasonUid});

  @override
  _AddTrainingScreenState createState() {
    return _AddTrainingScreenState();
  }
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _timeTrainingFormKey = GlobalKey<TrainingEditFormState>();
  final _detailsTrainingFormKey = GlobalKey<TrainingEditFormState>();
  final _repeatKey = GlobalKey<RepeatDetailsState>();
  var _teamStepState = StepState.editing;
  var _clubStepState = StepState.editing;
  var _detailsStepState = StepState.disabled;
  var _repeatStepState = StepState.disabled;
  var _createStepStage = StepState.disabled;
  Team _team;
  Game _initGame;
  var _repeatData = RepeatData((b) => b
    ..repeatInterval = 1
    ..repeatUntil = true
    ..endRepeat = clock.now()
    ..period = RepeatPeriod.None);
  int _currentStep = 0;
  List<TZDateTime> _repeatDates;
  AddTrainingBloc addTrainingBloc;

  Club _club;
  bool _clubEnabled;

  @override
  void initState() {
    super.initState();
    final clubBloc = BlocProvider.of<ClubBloc>(context);
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
      _detailsStepState = StepState.editing;
      _currentStep = 2;
      var teamBloc = BlocProvider.of<TeamBloc>(context);
      _team = teamBloc.state.getTeam(widget.teamUid);
      _teamChanged(_team);
      _initGame = _initGame.rebuild((b) => b..seasonUid = widget.seasonUid);
    }
    addTrainingBloc = AddTrainingBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _buildForm(BuildContext context, TrainingEditFormDisplay display) {
    GlobalKey<TrainingEditFormState> key;
    switch (display) {
      case TrainingEditFormDisplay.all:
        throw ArgumentError('not a good argument');
        break;
      case TrainingEditFormDisplay.timePlace:
        key = _timeTrainingFormKey;
        break;

      case TrainingEditFormDisplay.details:
        key = _detailsTrainingFormKey;
        break;
    }
    if (_initGame != null) {
      return TrainingEditForm(
        game: _initGame,
        key: key,
        displaySection: display,
      );
    } else {
      return SizedBox(height: 0, width: 0);
    }
  }

  Widget _buildRepeat(BuildContext context) {
    if (_initGame != null) {
      return RepeatDetailsWidget(
        _initGame.sharedData.tzTime,
        _repeatData,
        key: _repeatKey,
      );
    } else {
      return SizedBox(height: 0, width: 0);
    }
  }

  Future<bool> _saveTraining() async {
    var uuid = Uuid();
    var seriesId = uuid.v4();
    _initGame = _initGame.rebuild((b) => b..seriesId = seriesId);
    addTrainingBloc.add(
        AddTrainingEventCommit(newGame: _initGame, repeatTimes: _repeatDates));

    return true;
  }

  Widget _buildRepeatSummary() {
    if (_repeatDates == null) {
      return Text(Messages.of(context).unknown);
    }
    var myGame = _initGame;
    String timeStr;
    var start = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
    var end = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzEndTime));
    if (myGame.sharedData.time != myGame.sharedData.endTime) {
      timeStr = '$start - $end';
    } else {
      timeStr = MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
    }
    var cols = <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: Theme.of(context).accentColor,
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
        title: Text(myGame.sharedData.place.name ?? ''),
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
    cols.add(
      Text(
        Messages.of(context).trainingTimes,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );

    for (var t in _repeatDates) {
      cols.add(
        ListTile(
          leading: Icon(MdiIcons.calendarPlus),
          title: Text(
            MaterialLocalizations.of(context).formatFullDate(t),
          ),
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
  }

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      case 0:
        _teamStepState = StepState.editing;
        _clubStepState = StepState.complete;
        break;
      // Check to make sure a team is picked.
      case 1:
        if (_team == null) {
          _teamStepState = StepState.error;
          return false;
        }
        _teamStepState = StepState.complete;
        _detailsStepState = StepState.editing;
        _repeatStepState = StepState.disabled;
        break;
      // Verify the form is correct.
      case 2:
        if (backwards) {
          // Can always leave this step.
          _detailsStepState = StepState.editing;
          return true;
        }
        if (!_timeTrainingFormKey.currentState.validate()) {
          _detailsStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _timeTrainingFormKey.currentState.autoValidate = true;
          _repeatStepState = StepState.disabled;
          return false;
        }
        _timeTrainingFormKey.currentState.save();
        _initGame = _timeTrainingFormKey.currentState.finalGameResult.build();
        _detailsStepState = StepState.complete;
        _repeatStepState = StepState.editing;
        break;
      case 3:
        if (backwards) {
          // Can always leave this step.
          _detailsStepState = StepState.editing;
          return true;
        }
        if (!_detailsTrainingFormKey.currentState.validate()) {
          _detailsStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _detailsTrainingFormKey.currentState.autoValidate = true;
          _repeatStepState = StepState.disabled;
          return false;
        }
        _detailsTrainingFormKey.currentState.save();
        _initGame =
            _detailsTrainingFormKey.currentState.finalGameResult.build();
        _detailsStepState = StepState.complete;
        _repeatStepState = StepState.editing;
        break;
      case 4:
        if (!_repeatKey.currentState.validate()) {
          _showInSnackBar('Please fix the errors in red before submitting.');
          return false;
        }
        _repeatData = _repeatKey.currentState.save();
        _repeatStepState = StepState.complete;
        _createStepStage = StepState.complete;
        _repeatDates = _repeatData.repeatTimes(_initGame.sharedData.tzTime);
        break;
      case 5:
        _createStepStage = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (_currentStep < 5) {
          _currentStep++;
        } else {
          // Write the game out.
          _saveTraining().then((y) {
            Navigator.pop(context);
          }).catchError((e) {
            showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Error saving the training'),
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
        ..type = EventType.Practice
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
    final baseTimeDate = clock.now().add(const Duration(days: 1));
    final start = DateTime(
      baseTimeDate.year,
      baseTimeDate.month,
      baseTimeDate.day,
      12,
      0,
    );
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

  Widget _buildVerticalControls(BuildContext context,
      {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    var themeData = Theme.of(context);
    var localizations = MaterialLocalizations.of(context);
    final colorScheme = themeData.colorScheme;
    const OutlinedBorder buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)));
    const buttonPadding = EdgeInsets.symmetric(horizontal: 16.0);
    final lastAsDone = true;

    final row = Row(
      children: <Widget>[
        TextButton(
          onPressed: onStepContinue,
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return states.contains(MaterialState.disabled)
                  ? null
                  : (LocalUtilities.isDark(context)
                      ? colorScheme.onSurface
                      : colorScheme.onPrimary);
            }),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return LocalUtilities.isDark(context) ||
                      states.contains(MaterialState.disabled)
                  ? null
                  : colorScheme.primary;
            }),
            padding:
                MaterialStateProperty.all<EdgeInsetsGeometry>(buttonPadding),
            shape: MaterialStateProperty.all<OutlinedBorder>(buttonShape),
          ),
          key: Key('CONTINUE'),
          child: _currentStep == 5 && lastAsDone
              ? Text(Messages.of(context).doneButton)
              : Text(localizations.continueButtonLabel),
        ),
        (_currentStep == 0
            ? Container(
                margin: const EdgeInsetsDirectional.only(start: 8.0),
                child: TextButton(
                  onPressed: () => setState(() => _currentStep++),
                  style: TextButton.styleFrom(
                    primary: cancelColor,
                    padding: buttonPadding,
                    shape: buttonShape,
                  ),
                  key: Key('BACK'),
                  child: Text(Messages.of(context).skipButton),
                ),
              )
            : SizedBox(width: 0)),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 8.0),
          child: TextButton(
            onPressed: onStepCancel,
            style: TextButton.styleFrom(
              primary: cancelColor,
              padding: buttonPadding,
              shape: buttonShape,
            ),
            key: Key('BACK'),
            child: Text(localizations.cancelButtonLabel),
          ),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: KeyboardVisibilityBuilder(builder: (context, isVisible) {
          // Make the continue button be visible.
          Timer(Duration(milliseconds: 50),
              () => Scrollable.ensureVisible(context));
          return row;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return BlocProvider(
      create: (c) => addTrainingBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(messages.title),
        ),
        body: BlocListener(
          bloc: addTrainingBloc,
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
                    content: Text('Error saving the training'),
                  );
                },
              );
            }
          },
          child: BlocBuilder(
            bloc: addTrainingBloc,
            builder: (context, addState) => SavingOverlay(
              saving: addState is AddItemSaving,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  physics: ClampingScrollPhysics(),
                  controlsBuilder: _buildVerticalControls,
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
                      subtitle: _currentStep > 0
                          ? _club == null
                              ? Text(Messages.of(context).noClub)
                              : Text(_club.name)
                          : null,
                      state: _clubStepState,
                      isActive: _clubEnabled,
                      content: Column(
                        children: [
                          ClubSelection(
                            onChanged: _clubChanged,
                            initialClub: _club,
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: Text(messages.team),
                      subtitle: _currentStep > 1 ? Text(_team.name) : null,
                      state: _teamStepState,
                      isActive: true,
                      content: TeamSelection(
                        club: _club,
                        onChanged: _teamChanged,
                        initialTeam: _team,
                      ),
                    ),
                    Step(
                      title: Text(messages.gameTime),
                      subtitle: _currentStep > 2
                          ? Text(
                              MaterialLocalizations.of(context).formatTimeOfDay(
                                  TimeOfDay.fromDateTime(
                                      _initGame.sharedData.tzTime)),
                            )
                          : null,
                      state: _detailsStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content: _buildForm(
                          context, TrainingEditFormDisplay.timePlace),
                    ),
                    Step(
                      title: Text(messages.details),
                      state: _detailsStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content:
                          _buildForm(context, TrainingEditFormDisplay.details),
                      subtitle: _currentStep > 3
                          ? _initGame.uniform.isNotEmpty
                              ? Text(_initGame.uniform)
                              : _initGame.notes.isNotEmpty
                                  ? Text(_initGame.notes)
                                  : null
                          : null,
                    ),
                    Step(
                      title: Text(messages.repeat),
                      state: _repeatStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content: _buildRepeat(context),
                    ),
                    Step(
                      title: Text(messages.create),
                      state: _createStepStage,
                      isActive: _timeTrainingFormKey != null &&
                          _timeTrainingFormKey.currentState != null &&
                          _timeTrainingFormKey.currentState.validate(),
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
