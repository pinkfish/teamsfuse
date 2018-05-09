import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/games/trainingeditform.dart';
import 'package:flutter_fuse/widgets/games/repeatdetails.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:timezone/timezone.dart';

class AddTrainingScreen extends StatefulWidget {
  AddTrainingScreen();

  @override
  AddTrainingScreenState createState() {
    return new AddTrainingScreenState();
  }
}

class AddTrainingScreenState extends State<AddTrainingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<TrainingEditFormState> _trainingFormKey =
      new GlobalKey<TrainingEditFormState>();
  final GlobalKey<RepeatDetailsState> _repeatKey =
      new GlobalKey<RepeatDetailsState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState repeatStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  String _teamUid;
  Game _initGame;
  RepeatData repeatData = new RepeatData();
  int currentStep = 0;
  List<TZDateTime> _repeatDates;

  AddTrainingScreenState();

  @override
  void initState() {
    newGame();
    super.initState();
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
      _initGame.tzTime,
      repeatData,
      key: _repeatKey,
    );
  }

  Widget _buildRepeatSummary() {
    print("${_trainingFormKey.currentState} ${_repeatKey.currentState}");
    if (_repeatDates == null) {
      return new Text(Messages.of(context).unknown);
    }
    Game myGame = _initGame;
    String timeStr;
    print("game -- ${myGame.time} ${myGame.endTime}");
    if (myGame.time != myGame.endTime) {
      timeStr = MaterialLocalizations
              .of(context)
              .formatTimeOfDay(new TimeOfDay.fromDateTime(myGame.tzTime)) +
          " - " +
          MaterialLocalizations
              .of(context)
              .formatTimeOfDay(new TimeOfDay.fromDateTime(myGame.tzEndTime));
    } else {
      timeStr = MaterialLocalizations
          .of(context)
          .formatTimeOfDay(new TimeOfDay.fromDateTime(myGame.tzTime));
    }
    List<Widget> cols = [
      new RaisedButton(
        child: new Text(Messages.of(context).createnew),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () => _onStepperContinue(context),
      ),
      new ListTile(
        leading: const Icon(Icons.calendar_today),
        title: new Text(
            MaterialLocalizations.of(context).formatFullDate(myGame.tzTime)),
        subtitle: new Text(timeStr),
      ),
      new ListTile(
        leading: const Icon(Icons.place),
        title: new Text(myGame.place.name != null ? myGame.place.name : ""),
        subtitle:
            new Text(myGame.place.address != null ? myGame.place.address : ""),
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
          leading: const Icon(CommunityIcons.tshirtcrew),
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
          leading: const Icon(CommunityIcons.calendarplus),
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
        if (_teamUid == null) {
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
        detailsStepState = StepState.complete;
        repeatStepState = StepState.editing;
        break;
      case 2:
        if (!_repeatKey.currentState.validate()) {
          _showInSnackBar('Please fix the errors in red before submitting.');
          return false;
        }
        _repeatKey.currentState.save();
        repeatStepState = StepState.complete;
        createStepStage = StepState.complete;
        _repeatDates = _repeatKey.currentState.repeatTimes(_initGame.tzTime);
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
          Game myGame = _initGame;

          // Write the game out.
          _initGame.updateFirestore().then((void y) {
          Navigator.pop(context);

          })
          .catchError((Error e) {
            showDialog(
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
    _initGame = new Game.newGame(EventType.Practice);
    _initGame.opponentUid = null;
    _initGame.homegame = false;
    _initGame.uniform = '';
    _initGame.notes = '';
  }

  void _teamChanged(String str) {
    _teamUid = str;
    _initGame.teamUid = _teamUid;
    Team teamData = UserDatabaseData.instance.teams[_teamUid];
    DateTime start = new DateTime.now().add(const Duration(days: 0));
    _initGame.time = start.millisecondsSinceEpoch;
    _initGame.endTime = _initGame.time;
    _initGame.seasonUid = teamData.currentSeason;

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
              title: new Text(messages.team),
              state: teamStepState,
              isActive: true,
              content: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new TeamPicker(onChanged: this._teamChanged),
                ],
              ),
            ),
            new Step(
              title: new Text(messages.gamedetails),
              state: detailsStepState,
              isActive: _teamUid != null && _teamUid.isNotEmpty,
              content: this._buildForm(context),
            ),
            new Step(
              title: new Text(messages.repeat),
              state: repeatStepState,
              isActive: _teamUid != null && _teamUid.isNotEmpty,
              content: this._buildRepeat(context),
            ),
            new Step(
              title: new Text(messages.gamecreate),
              state: createStepStage,
              isActive: _trainingFormKey != null &&
                  _trainingFormKey.currentState != null &&
                  _trainingFormKey.currentState.validate(),
              content: _buildRepeatSummary(),
            )
          ],
        ),
      ),
    );
  }
}
