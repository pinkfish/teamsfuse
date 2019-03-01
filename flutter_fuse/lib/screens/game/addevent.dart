import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/eventeditform.dart';
import 'package:flutter_fuse/widgets/teams/teamselection.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/fusemodel.dart';

class AddEventScreen extends StatefulWidget {
  AddEventScreen();

  @override
  AddEventScreenState createState() {
    return new AddEventScreenState();
  }
}

class AddEventScreenState extends State<AddEventScreen> {
  AddEventScreenState();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<EventEditFormState> _eventFormKey =
      new GlobalKey<EventEditFormState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  Team _team;
  Game _initGame;
  int currentStep = 0;

  @override
  void initState() {
    newGame();
    super.initState();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return new EventEditForm(
      game: _initGame,
      key: _eventFormKey,
    );
  }

  Widget _buildRepeatSummary() {
    print("${_eventFormKey.currentState}");
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
        title: new Text(
            myGame.sharedData.place.name ?? Messages.of(context).unknown),
        subtitle: new Text(myGame.sharedData.place.address ?? ""),
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
        _initGame = _eventFormKey.currentState.finalGameResult;
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
          _initGame.updateFirestore(false).then((void y) {
            Navigator.pop(context);
          }).catchError((Error e) {
            showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: new Text("Error"),
                  content: new Text("Error saving the training"),
                );
              },
            );
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
    GameSharedData sharedGameData =
        new GameSharedData(_team.uid, null, type: EventType.Event);
    _initGame = new Game(_team.uid, null, sharedData: sharedGameData);
    _initGame.opponentUids = <String>[];
    _initGame.homegame = false;
    _initGame.uniform = '';
    _initGame.notes = '';
  }

  void _teamChanged(Team team) {
    setState(() {
      _team = team;
    });
    _initGame.teamUid = _team.uid;
    DateTime start = new DateTime.now().add(const Duration(days: 0));
    _initGame.sharedData.time = start.millisecondsSinceEpoch;
    _initGame.sharedData.endTime = _initGame.sharedData.time;
    _initGame.seasonUid = _team.currentSeason;
    _initGame.trackAttendance = _team.trackAttendence;

    print('team changed ${_initGame.toJSON()}');
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.title),
      ),
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        child: new Stepper(
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
              isActive: _team != null && ((_team?.uid?.isNotEmpty) ?? false),
              content: _buildForm(context),
            ),
            new Step(
              title: new Text(messages.create),
              state: createStepStage,
              isActive: _eventFormKey != null &&
                  _eventFormKey.currentState != null &&
                  _eventFormKey.currentState.validate(),
              content: _buildRepeatSummary(),
            )
          ],
        ),
      ),
    );
  }
}
