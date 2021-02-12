import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/games/eventeditform.dart';
import '../../widgets/teams/teamselection.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add screen to event to the game
///
class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() {
    return _AddEventScreenState();
  }
}

class _AddEventScreenState extends State<AddEventScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<EventEditFormState> _eventFormKey =
      GlobalKey<EventEditFormState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  Team _team;
  Game _initGame;
  int currentStep = 0;
  AddGameBloc addGameBloc;

  @override
  void initState() {
    newGame();
    super.initState();
    addGameBloc = AddGameBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
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
        var end = MaterialLocalizations.of(context)
            .formatTimeOfDay(
            TimeOfDay.fromDateTime(myGame.sharedData.tzEndTime));
        timeStr = "$start - $end";
      } else {
        timeStr = MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(myGame.sharedData.tzTime));
      }
      var cols = <Widget>[
        RaisedButton(
          child: Text(Messages
              .of(context)
              .createNew),
          color: Theme
              .of(context)
              .accentColor,
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
          title:
          Text(myGame.sharedData.place.name ?? Messages
              .of(context)
              .unknown),
          subtitle: Text(myGame.sharedData.place.address ?? ""),
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
      return SizedBox(height:0, width:0);
    }
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
        break;
      // Verify the form is correct.
      case 1:
        if (backwards) {
          // Can always leave this step.
          detailsStepState = StepState.editing;
          return true;
        }
        if (!_eventFormKey.currentState.validate()) {
          detailsStepState = StepState.error;
          createStepStage = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _eventFormKey.currentState.autoValidate = true;
          return false;
        }
        _eventFormKey.currentState.save();
        _initGame = _eventFormKey.currentState.finalGameResult.build();
        detailsStepState = StepState.complete;
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
          addGameBloc.add(AddGameEventCommit(newGame: _initGame));
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
    if (_team != null) {
      var start = DateTime.now().add(const Duration(days: 1));

      var sharedGameData = GameSharedData((b) => b
        ..uid = ""
        ..type = EventType.Event
        ..time = start
        ..endTime = start.add(const Duration(hours: 1))
        ..timezone = local.name
        ..officialResult.homeTeamLeagueUid = _team.uid);

      var result = GameResultDetailsBuilder()
        ..result = GameResult.Unknown
        ..inProgress = GameInProgress.NotStarted;

      _initGame = Game((b) => b
        ..teamUid = _team.uid
        ..sharedDataUid = ""
        ..sharedData = sharedGameData.toBuilder()
        ..uniform = ""
        ..uid = ""
        ..teamUid = _team.uid
        ..seasonUid = _team.currentSeason
        ..trackAttendance = _team.trackAttendenceInternal
        ..arrivalTime =
            start.subtract(Duration(minutes: _team.arriveEarlyInternal.toInt()))
        ..result = result
        ..notes = '');
    }
  }

  void _teamChanged(Team team) {
    _team = team;
    var start = DateTime.now().add(const Duration(days: 0));
    if (_initGame == null) {
      newGame();
    }

    setState(() {
      _initGame = _initGame.rebuild((b) => b
        ..teamUid = team.uid
        ..sharedData.time = start.toUtc()
        ..sharedData.endTime = _initGame.sharedData.time
        ..seasonUid = team.currentSeason
        ..trackAttendance = team.trackAttendenceInternal);
    });
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
              showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Error saving the event"),
                  );
                },
              );
            }
          },
          child: BlocBuilder(
            cubit: addGameBloc,
            builder: (context, state) => SavingOverlay(
              saving: state is AddItemSaving,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Stepper(
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
                      isActive:
                          _team != null && ((_team?.uid?.isNotEmpty) ?? false),
                      content: _buildForm(context),
                    ),
                    Step(
                      title: Text(messages.create),
                      state: createStepStage,
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
