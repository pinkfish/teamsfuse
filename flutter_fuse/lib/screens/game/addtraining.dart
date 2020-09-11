import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/repeatdetails.dart';
import 'package:flutter_fuse/widgets/games/trainingeditform.dart';
import 'package:flutter_fuse/widgets/teams/teamselection.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

class AddTrainingScreen extends StatefulWidget {
  AddTrainingScreen();

  @override
  AddTrainingScreenState createState() {
    return new AddTrainingScreenState();
  }
}

class AddTrainingScreenState extends State<AddTrainingScreen> {
  AddTrainingScreenState();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<TrainingEditFormState> _trainingFormKey =
      new GlobalKey<TrainingEditFormState>();
  final GlobalKey<RepeatDetailsState> _repeatKey =
      new GlobalKey<RepeatDetailsState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState repeatStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  Team _team;
  Game _initGame;
  RepeatData _repeatData = new RepeatData();
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
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new TrainingEditForm(
      game: _initGame,
      key: _trainingFormKey,
    );
  }

  Widget _buildRepeat(BuildContext context) {
    return new RepeatDetailsWidget(
      _initGame.sharedData.tzTime,
      _repeatData,
      key: _repeatKey,
    );
  }

  Future<bool> _saveTraining() async {
    Uuid uuid = new Uuid();
    String seriesId = uuid.v4();
    _initGame = _initGame.rebuild((b) => b..seriesId = seriesId);
    addTrainingBloc.add(
        AddTrainingEventCommit(newGame: _initGame, repeatTimes: _repeatDates));

    return true;
  }

  Widget _buildRepeatSummary() {
    print("${_trainingFormKey.currentState} ${_repeatKey.currentState}");
    if (_repeatDates == null) {
      return new Text(Messages.of(context).unknown);
    }
    Game myGame = _initGame;
    String timeStr;
    print("game -- ${myGame.sharedData.time} ${myGame.sharedData.endTime}");
    if (myGame.sharedData.time != myGame.sharedData.endTime) {
      timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
              new TimeOfDay.fromDateTime(myGame.sharedData.tzTime)) +
          " - " +
          MaterialLocalizations.of(context).formatTimeOfDay(
              new TimeOfDay.fromDateTime(myGame.sharedData.tzEndTime));
    } else {
      timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
          new TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
    }
    List<Widget> cols = <Widget>[
      new RaisedButton(
        child: new Text(Messages.of(context).createnew),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () => _onStepperContinue(context),
      ),
      new ListTile(
        leading: const Icon(Icons.calendar_today),
        title: new Text(MaterialLocalizations.of(context)
            .formatFullDate(myGame.sharedData.tzTime)),
        subtitle: new Text(timeStr),
      ),
      new ListTile(
        leading: const Icon(Icons.place),
        title: new Text(myGame.sharedData.place.name != null
            ? myGame.sharedData.place.name
            : ""),
        subtitle: new Text(myGame.sharedData.place.address != null
            ? myGame.sharedData.place.address
            : ""),
      ),
    ];

    if (myGame.notes.isNotEmpty) {
      cols.add(
        new ListTile(
          leading: const Icon(Icons.note),
          title: new Text(myGame.notes),
        ),
      );
    }
    if (myGame.uniform.isNotEmpty) {
      cols.add(
        new ListTile(
          leading: const Icon(CommunityIcons.tshirtCrew),
          title: new Text(myGame.uniform),
        ),
      );
    }
    cols.add(
      new Text(
        Messages.of(context).trainingtimes,
        style: Theme.of(context).textTheme.headline,
      ),
    );

    _repeatDates.forEach((DateTime t) {
      cols.add(
        new ListTile(
          leading: const Icon(CommunityIcons.calendarPlus),
          title: new Text(
            MaterialLocalizations.of(context).formatFullDate(t),
          ),
        ),
      );
    });

    return new Scrollbar(
      child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Column(
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
          _saveTraining().then((void y) {
            Navigator.pop(context);
          }).catchError((Error e) {
            showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text("Error"),
                    content: new Text("Error saving the training"),
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
    GameSharedData sharedGameData = new GameSharedData((b) => b
      ..type = EventType.Practice
      ..officialResult.homeTeamLeagueUid = _team.uid);
    _initGame = new Game((b) => b
      ..teamUid = _team.uid
      ..sharedData = sharedGameData.toBuilder()
      ..uniform = ""
      ..notes = '');
  }

  void _teamChanged(Team team) {
    DateTime start = new DateTime.now().add(const Duration(days: 0));
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
    Messages messages = Messages.of(context);

    return BlocProvider(
      create: (BuildContext c) => addTrainingBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(messages.title),
        ),
        body: BlocListener(
          cubit: addTrainingBloc,
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
                    content: new Text("Error saving the training"),
                  );
                },
              );
            }
          },
          child: BlocBuilder(
            cubit: addTrainingBloc,
            builder: (BuildContext context, AddItemState addState) =>
                SavingOverlay(
              saving: addState is AddItemSaving,
              child: Container(
                padding: new EdgeInsets.all(16.0),
                child: new StepperAlwaysVisible(
                  type: StepperType.horizontal,
                  currentStep: currentStep,
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
                      title: new Text(messages.team),
                      state: teamStepState,
                      isActive: true,
                      content: new TeamSelection(
                        club: null,
                        onChanged: _teamChanged,
                        initialTeam: _team,
                      ),
                    ),
                    new Step(
                      title: new Text(messages.details),
                      state: detailsStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content: _buildForm(context),
                    ),
                    new Step(
                      title: new Text(messages.repeat),
                      state: repeatStepState,
                      isActive: _team != null ? _team?.uid?.isNotEmpty : false,
                      content: _buildRepeat(context),
                    ),
                    new Step(
                      title: new Text(messages.create),
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
