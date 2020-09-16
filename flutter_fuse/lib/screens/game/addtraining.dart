import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

import '../../services/messages.dart';
import '../../widgets/games/repeatdetails.dart';
import '../../widgets/games/trainingeditform.dart';
import '../../widgets/teams/teamselection.dart';
import '../../widgets/util/communityicons.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/stepperalwaysvisible.dart';

///
/// Adds a traning session.
///
class AddTrainingScreen extends StatefulWidget {
  @override
  _AddTrainingScreenState createState() {
    return _AddTrainingScreenState();
  }
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<TrainingEditFormState> _trainingFormKey =
      GlobalKey<TrainingEditFormState>();
  final GlobalKey<RepeatDetailsState> _repeatKey =
      GlobalKey<RepeatDetailsState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState repeatStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  Team _team;
  Game _initGame;
  RepeatData _repeatData = RepeatData();
  int currentStep = 0;
  List<TZDateTime> _repeatDates;
  AddTrainingBloc addTrainingBloc;

  @override
  void initState() {
    newGame();
    super.initState();
    addTrainingBloc = AddTrainingBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return TrainingEditForm(
      game: _initGame,
      key: _trainingFormKey,
    );
  }

  Widget _buildRepeat(BuildContext context) {
    return RepeatDetailsWidget(
      _initGame.sharedData.tzTime,
      _repeatData,
      key: _repeatKey,
    );
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
    print("${_trainingFormKey.currentState} ${_repeatKey.currentState}");
    if (_repeatDates == null) {
      return Text(Messages.of(context).unknown);
    }
    var myGame = _initGame;
    String timeStr;
    print("game -- ${myGame.sharedData.time} ${myGame.sharedData.endTime}");
    var start = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
    var end = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzEndTime));
    if (myGame.sharedData.time != myGame.sharedData.endTime) {
      timeStr = "$start - $end";
    } else {
      timeStr = MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
    }
    var cols = <Widget>[
      RaisedButton(
        child: Text(Messages.of(context).createNew),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () => _onStepperContinue(context),
      ),
      ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text(MaterialLocalizations.of(context)
            .formatFullDate(myGame.sharedData.tzTime)),
        subtitle: Text(timeStr),
      ),
      ListTile(
        leading: Icon(Icons.place),
        title: Text(myGame.sharedData.place.name != null
            ? myGame.sharedData.place.name
            : ""),
        subtitle: Text(myGame.sharedData.place.address != null
            ? myGame.sharedData.place.address
            : ""),
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
          leading: Icon(CommunityIcons.tshirtCrew),
          title: Text(myGame.uniform),
        ),
      );
    }
    cols.add(
      Text(
        Messages.of(context).trainingtimes,
        style: Theme.of(context).textTheme.subtitle1,
      ),
    );

    for (var t in _repeatDates) {
      cols.add(
        ListTile(
          leading: Icon(CommunityIcons.calendarPlus),
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
    switch (currentStep) {
      // Check to make sure a team is picked.
      case 0:
        if (_team == null) {
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
        _initGame = _trainingFormKey.currentState.finalGameResult.build();
        detailsStepState = StepState.complete;
        repeatStepState = StepState.editing;
        break;
      case 2:
        if (!_repeatKey.currentState.validate()) {
          _showInSnackBar('Please fix the errors in red before submitting.');
          return false;
        }
        _repeatData = _repeatKey.currentState.save();
        repeatStepState = StepState.complete;
        createStepStage = StepState.complete;
        _repeatDates = _repeatData.repeatTimes(_initGame.sharedData.tzTime);
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
        if (currentStep < 3) {
          currentStep++;
        } else {
          // Write the game out.
          _saveTraining().then((y) {
            Navigator.pop(context);
          }).catchError((e) {
            showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Error saving the training"),
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

  void newGame() {
    var sharedGameData = GameSharedData((b) => b
      ..type = EventType.Practice
      ..officialResult.homeTeamLeagueUid = _team.uid);
    _initGame = Game((b) => b
      ..teamUid = _team.uid
      ..sharedData = sharedGameData.toBuilder()
      ..uniform = ""
      ..notes = '');
  }

  void _teamChanged(Team team) {
    var start = DateTime.now().add(const Duration(days: 0));
    _initGame = _initGame.rebuild((b) => b
      ..teamUid = team.uid
      ..sharedData.time = start.millisecondsSinceEpoch
      ..sharedData.endTime = _initGame.sharedData.time
      ..seasonUid = team.currentSeason
      ..trackAttendance = team.trackAttendenceInternal);

    print('team changed ${_initGame.toMap()}');
    setState(() {
      _team = team;
    });
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
          cubit: addTrainingBloc,
          listener: (context, state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Error saving the training"),
                  );
                },
              );
            }
          },
          child: BlocBuilder(
            cubit: addTrainingBloc,
            builder: (context, addState) => SavingOverlay(
              saving: addState is AddItemSaving,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: StepperAlwaysVisible(
                  type: StepperType.horizontal,
                  currentStep: currentStep,
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
                      title: Text(messages.team),
                      state: teamStepState,
                      isActive: true,
                      content: TeamSelection(
                        club: null,
                        onChanged: _teamChanged,
                        initialTeam: _team,
                      ),
                    ),
                    Step(
                      title: Text(messages.details),
                      state: detailsStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content: _buildForm(context),
                    ),
                    Step(
                      title: Text(messages.repeat),
                      state: repeatStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content: _buildRepeat(context),
                    ),
                    Step(
                      title: Text(messages.create),
                      state: createStepStage,
                      isActive: _trainingFormKey != null &&
                          _trainingFormKey.currentState != null &&
                          _trainingFormKey.currentState.validate(),
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
