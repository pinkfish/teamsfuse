import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/datetimeformfield.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/form/opponentformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'addopponent.dart';

class EditGame extends StatefulWidget {
  String gameuid;

  EditGame(this.gameuid);

  @override
  EditGameState createState() {
    return new EditGameState(this.gameuid);
  }
}

class EditGameState extends State<EditGame> {
  Game _game;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<DateTimeFormFieldState> _arriveByKey = new GlobalKey<
      DateTimeFormFieldState>();
  final GlobalKey<OpponentFormFieldState> _opponentState = new GlobalKey<OpponentFormFieldState>();
  StepState teamStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  int currentStep = 0;
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  DateTimeUnion _atDate = new DateTimeUnion(
      new DateTime.now(), const TimeOfDay(hour: 7, minute: 28));
  DateTimeUnion _arriveAtDate = new DateTimeUnion(
      new DateTime.now(), const TimeOfDay(hour: 7, minute: 28));
  FocusNode _focusNode = new FocusNode();

  EditGameState(String gameuid) {
    if (UserDatabaseData.instance.games.containsKey(gameuid)) {
      this._game = UserDatabaseData.instance.games[gameuid];
    } else {
      this._game = new Game.newGame(EventType.Game);
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _teamChanged(String team) {
    Team teamData = UserDatabaseData.instance.teams[team];
    num hour = _atDate.item2.hour;
    num minute = _atDate.item2.minute - teamData.arriveEarly;
    if (minute < 0) {
      hour -= minute / 60;
      minute = 60 - (minute % 60);
    }
    _arriveAtDate =
    new DateTimeUnion(
        _atDate.item1, new TimeOfDay(hour: hour, minute: minute));
    _game.teamUid = team;
  }

  void _changeAtTime(DateTimeUnion union) {
    TimeOfDay curTime = _arriveByKey.currentState.value.item2;
    // Get the diff with the arrive time and then make the same diff...
    num cur = union.item2.hour * 60 + union.item2.minute;
    num arriveAt = curTime.hour * 60 + curTime.minute;
    num diff = cur - arriveAt;

    num hour = union.item2.hour;
    num minute = union.item2.minute - diff;

    hour += ((minute / 60) % 24).toInt();
    if (minute < 0) {
      minute = 60 + (minute % 60);
    } else if (minute > 60) {
      minute = (minute % 60);
    }

    _arriveByKey.currentState.setValue(
        new DateTimeUnion(
            union.item1, new TimeOfDay(hour: hour, minute: minute)));
  }

  void _openAddOpponentDialog() async {
    String save = await Navigator.of(context).push(new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return new AddOpponent(this._game.teamUid);
        },
        fullscreenDialog: true
    ));
    print('save ${save}');

    if (save != null) {
       _opponentState.currentState.setValue(save);
    }
  }

  Widget _buildForm(BuildContext context) {
    if (_game.teamUid == null ||
        !UserDatabaseData.instance.teams.containsKey(_game.teamUid)) {
      return new Text('Invalid state');
    }
    Team team = UserDatabaseData.instance.teams[_game.teamUid];
    return new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Form(
                  key: _formKey,
                  autovalidate: _autovalidate,
                  child: new DropdownButtonHideUnderline(
                      child: new Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment
                                .end,
                            children: <Widget>[
                              new Expanded(
                                  flex: 1,
                                  child:
                                  new SeasonFormField(
                                      initialValue: team.currentSeason,
                                      teamUid: _game.teamUid,
                                      onSaved: ((String value) {
                                        _game.seasonUid = value;
                                      })
                                  )
                              ),
                              const SizedBox(width: 12.0),
                              new Expanded(
                                flex: 1,
                                child:
                                new OpponentFormField(
                                    teamUid: _game.teamUid,
                                    key: _opponentState,
                                    initialValue: 'none',
                                    validator: (String str) {
                                      print('validate ${str}');
                                      return _validations.validateOpponent(
                                          context, str);
                                    },
                                    onFieldSubmitted: (String value) {
                                      if (value == 'add') {
                                        // Open up a picker to create an opponent.
                                        _openAddOpponentDialog();
                                      }
                                    },
                                    onSaved: ((String value) {
                                      _game.opponentUid = value;
                                    })),
                              ),
                            ],
                          ),
                          new DateTimeFormField(
                            labelText: Messages
                                .of(context)
                                .gametime,
                            initialValue: _atDate,
                            hideDate: false,
                            onSaved: (DateTimeUnion value) {
                              _atDate = value;
                            },
                            onFieldSubmitted: this
                                ._changeAtTime,
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment
                                .end,
                            children: <Widget>[
                              new Expanded(
                                flex: 4,
                                child: new DateTimeFormField(
                                  key: _arriveByKey,
                                  labelText: Messages
                                      .of(context)
                                      .arriveat,
                                  initialValue: _arriveAtDate,
                                  hideDate: true,
                                  onSaved: (DateTimeUnion val) {
                                    _arriveAtDate = val;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              new Expanded(
                                flex: 1,
                                child: new SwitchFormField(
                                  decoration: new InputDecoration(
                                    labelText: Messages
                                        .of(context)
                                        .homeaway,
                                  ),
                                  onSaved: (bool value) {
                                    _game.homegame = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          new EnsureVisibleWhenFocused(focusNode: _focusNode,
                            child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(
                                      Icons.event_note),
                                  hintText: Messages
                                      .of(context)
                                      .uniformhint,
                                  labelText: Messages
                                      .of(context)
                                      .uniform,
                                ),
                                keyboardType: TextInputType
                                    .text,
                                obscureText: false,
                                onSaved: (String value) {
                                  _game.uniform = value;
                                }
                            ),
                          ),
                          new EnsureVisibleWhenFocused(focusNode: _focusNode,
                            child:
                            new TextFormField(
                                decoration: const InputDecoration(
                                    icon: const Icon(Icons.note),
                                    hintText: 'Game notes',
                                    labelText: 'Game notes'
                                ),
                                keyboardType: TextInputType
                                    .text,
                                obscureText: false,
                                onSaved: (String value) {
                                  _game.notes = value;
                                }
                            ),
                          ),
                        ],
                      )
                  )
              )
            ])
    );
  }

  bool _leaveCurrentState(bool backwards) {
    switch (currentStep) {
    // Check to make sure a team is picked.
      case 0:
        if (_game.teamUid == null) {
          print('teamuid ${_game.teamUid}');
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
        if (!_formKey.currentState.validate()) {
          detailsStepState = StepState.error;
          createStepStage = StepState.disabled;
          _showInSnackBar('Please fix the errors in red before submitting.');
          _autovalidate = true;
          return false;
        }
        _formKey.currentState.save();
        detailsStepState = StepState.complete;
        createStepStage = StepState.complete;
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
        currentStep ++;
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(Messages
              .of(context)
              .title),
        ),
        body: new Container(
            padding: new EdgeInsets.all(16.0),
            child:
            new Stepper(
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
                    title: new Text(Messages
                        .of(context)
                        .teamselect),
                    state: teamStepState,
                    isActive: true,
                    content: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new TeamPicker(this._teamChanged)
                      ],
                    )
                ),
                new Step(
                    title: const Text('Setup team'),
                    state: detailsStepState,
                    isActive: _game.teamUid != '' && _game.teamUid != null,
                    content: this._buildForm(context)
                ),
                new Step(
                    title: const Text('Create'),
                    state: createStepStage,
                    isActive: _formKey.currentState != null &&
                        _formKey.currentState.validate(),
                    content: new Text('Stuff')
                )
              ],
            )
        )
    );
  }
}