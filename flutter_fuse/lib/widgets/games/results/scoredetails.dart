import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../../../services/blocs.dart';
import '../../../services/messages.dart';
import '../../../util/debouncer.dart';
import '../..//util/numberpicker.dart';
import '../../util/stopwatchdisplay.dart';
import 'changescoredialog.dart';
import 'periodselector.dart';
import 'timersetupdialog.dart';

///
/// Shows the details of the score.
///
class ScoreDetails extends StatefulWidget {
  /// Constructor.
  ScoreDetails(this.game, this.team);

  /// Game to show the score for,
  final SingleGameBloc game;

  /// Team to show the score for.
  final Team team;

  @override
  State createState() {
    return _ScoreDetailsState();
  }
}

class _ScoreDetailsState extends State<ScoreDetails> {
  final MyStopwatch stopwatch = MyStopwatch();
  GameResultPerPeriodBuilder _currentPeriodResults;
  GameResultDetailsBuilder _details;
  num _ptsFor;
  num _ptsAgainst;
  Debouncer<bool> _debouncer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<NumberPickerState> _ptsForState =
      GlobalKey<NumberPickerState>();
  final GlobalKey<NumberPickerState> _ptsAgainstState =
      GlobalKey<NumberPickerState>();

  Game _lastGame;

  @override
  void initState() {
    super.initState();
    _details = widget.game.state.game.result.toBuilder();
    if (widget.game.state.game.result.currentPeriod != null) {
      _currentPeriodResults = widget.game.state.game.result
          .scores[widget.game.state.game.result.currentPeriod]
          .toBuilder();
    }
    var periodZero = GamePeriod((b) => b
      ..type = widget.game.state.game.result.currentPeriod.type
      ..periodNumber = 1);
    if (_currentPeriodResults == null) {
      _currentPeriodResults =
          widget.game.state.game.result.scores[periodZero].toBuilder();
    }
    if (_currentPeriodResults == null) {
      var gameScoreBuilder = GameScoreBuilder()
        ..ptsAgainst = 0
        ..ptsFor = 0;
      _currentPeriodResults = GameResultPerPeriodBuilder()
        ..period = periodZero.toBuilder()
        ..score = gameScoreBuilder;

      _details.scoresInternal[periodZero] = _currentPeriodResults.build();
    }
    if (_details.currentPeriod == null) {
      _details.currentPeriod = _currentPeriodResults.period;
    }
    _debouncer = Debouncer<bool>(Duration(seconds: 1), _sendUpdate,
        resetOnAdd: false, atBegin: true);
    _ptsFor = _currentPeriodResults.score.ptsFor;
    _ptsAgainst = _currentPeriodResults.score.ptsAgainst;
    // Setup the stop watch/
    stopwatch.resetTo(_details.time.build().currentStopwatch().inMilliseconds);
    if (_details.time.currentPeriodStartInternal != null) {
      stopwatch.start();
    }
  }

  void _updateGame(Game game) {
    // Change scores and timers.
    var period = GamePeriod((b) => b
      ..type = game.result.currentPeriod.type
      ..periodNumber = 0);
    if (game.result.scores.containsKey(period)) {
      _ptsForState.currentState
          .animateInt(game.result.scores[period].score.ptsFor.toInt());
      _ptsAgainstState.currentState
          .animateInt(game.result.scores[period].score.ptsAgainst.toInt());
    }

    // If the period changed, update stuff.
    if (game.result.currentPeriod != _details.currentPeriod.build()) {
      _periodChanged(game.result.currentPeriod);
    }

    setState(() {
      if (game.result.scores.containsKey(period)) {
        _currentPeriodResults.period =
            game.result.scores[period].period.toBuilder();
      }
      _details.currentPeriod = game.result.currentPeriod.toBuilder();
    });
  }

  void _periodChanged(GamePeriod newPeriod) {
    if (newPeriod.type != _currentPeriodResults.period.type) {
      _setPeriodType(newPeriod);
    }
    _currentPeriodResults.period = newPeriod.toBuilder();
    _details.currentPeriod = newPeriod.toBuilder();
    _writeLog(GameLogType.PeriodStart);
    widget.game.add(SingleGameUpdateResult(result: _details.build()));
  }

  void _setPeriodType(GamePeriod newPeriod) {
    var scoreUpdate = GamePeriodBuilder()
      ..type = _currentPeriodResults.period.type
      ..periodNumber = 0;
    _details.scoresInternal[scoreUpdate.build()] =
        _currentPeriodResults.build();
    // Create a score type.
    var newScoreUpdate = GamePeriod((b) => b
      ..periodNumber = 0
      ..type = scoreUpdate.type);
    if (!_details.scoresInternal
        .build()
        .containsKey(newScoreUpdate.toIndex())) {
      var builder = GameScoreBuilder()
        ..ptsFor = 0
        ..ptsAgainst = 0;
      _details.scoresInternal[newScoreUpdate] = (GameResultPerPeriodBuilder()
            ..period = newScoreUpdate.toBuilder()
            ..score = builder)
          .build();
    }
    setState(() {
      _currentPeriodResults =
          _details.scoresInternal[newScoreUpdate.toIndex()].toBuilder();
      _currentPeriodResults.period = newPeriod.toBuilder();
    });
  }

  void _sendUpdate(List<bool> results) {
    widget.game.add(SingleGameUpdateResult(result: _details.build()));
  }

  void _updateScore() async {
    setState(() {
      if (_ptsAgainst != null) {
        _currentPeriodResults.score.ptsAgainst = _ptsAgainst;
      }
      if (_ptsFor != null) {
        _currentPeriodResults.score.ptsFor = _ptsFor;
      }
      _details.scoresInternal[_currentPeriodResults.period.build()] =
          _currentPeriodResults.build();
      //widget.game.updateFirestoreResult(_details);
      _writeLog(GameLogType.ScoreUpdate);
    });
    _debouncer.debounce(true);
  }

  void _finishGame() async {
    // Finalize game?
    GameResult gameResult;
    if (_currentPeriodResults.score.ptsFor >
        _currentPeriodResults.score.ptsAgainst) {
      gameResult = GameResult.Win;
    } else if (_currentPeriodResults.score.ptsFor <
        _currentPeriodResults.score.ptsAgainst) {
      gameResult = GameResult.Loss;
    } else {
      gameResult = GameResult.Tie;
    }
    var ret = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Messages.of(context).finalscore),
            content: Text(Messages.of(context).finalScoreBody(
                _currentPeriodResults.score.ptsFor,
                _currentPeriodResults.score.ptsAgainst,
                gameResult.toString())),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              )
            ],
          );
        });
    if (ret != null && ret == true) {
      // Save the state update.
      setState(() {
        if (_ptsAgainst != null) {
          _currentPeriodResults.score.ptsAgainst = _ptsAgainst;
        }
        if (_ptsFor != null) {
          _currentPeriodResults.score.ptsFor = _ptsFor;
        }
        _currentPeriodResults.period = GamePeriodBuilder()
          ..type = GamePeriodType.Regulation;
        _details.scoresInternal[_currentPeriodResults.period.build()] =
            _currentPeriodResults.build();
        _details.inProgress = GameInProgress.Final;
        _details.result = gameResult;
        _writeLog(GameLogType.PeriodStop);
      });
      // Save the game and exit.
      widget.game.add(SingleGameUpdateResult(result: _details.build()));
      Navigator.pop(context);
    }
  }

  Future<void> _startGame() async {
    if (widget.team.sport == Sport.Soccer) {
      return _startGameSimple();
    }
    // Ask if they are sure
    var ret = await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(Messages.of(context).choosedivisions),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, GameDivisionsType.Halves);
                },
                child: const Text('Halves'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, GameDivisionsType.Thirds);
                },
                child: const Text('Thirds'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, GameDivisionsType.Quarters);
                },
                child: const Text('Quarters'),
              ),
            ],
          );
        });
    if (ret != null) {
      // Save the state update.
      setState(() {
        _details.divisons = ret;
        _details.inProgress = GameInProgress.InProgress;
        _details.time.currentPeriodStartInternal = null;
        _details.time.currentOffsetInternal = 0;
        _details.currentPeriod = GamePeriodBuilder()
          ..type = GamePeriodType.Regulation
          ..periodNumber = 1;
        _writeLog(GameLogType.PeriodStart);
        widget.game.add(SingleGameUpdateResult(result: _details.build()));
      });
    }
  }

  Future<void> _startGameSimple() async {
    // Ask if they are sure
    var ret = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Messages.of(context).startgame),
            content: Text(Messages.of(context).startgamebody),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              )
            ],
          );
        });
    if (ret != null && ret == true) {
      // Save the state update.
      setState(() {
        _details.divisons = GameDivisionsType.Halves;
        _details.inProgress = GameInProgress.InProgress;
        // Timer not running.
        _details.time.currentPeriodStartInternal = null;
        _details.time.currentOffsetInternal = 0;
        _details.currentPeriod = GamePeriodBuilder()
          ..type = GamePeriodType.Regulation
          ..periodNumber = 1;
        _writeLog(GameLogType.PeriodStart);
        widget.game.add(SingleGameUpdateResult(result: _details.build()));
      });
    }
  }

  void _writeLog(GameLogType type, {String message}) {
    widget.game.add(SingleGameAddGameLog(
        log: (GameLogBuilder()
              ..type = type
              ..message = message
              ..score = _currentPeriodResults.score
              ..period = _currentPeriodResults.period
              ..eventTimeInternal = DateTime.now().microsecondsSinceEpoch
              ..uid =
                  BlocProvider.of<AuthenticationBloc>(context).currentUser.uid
              ..displayName = BlocProvider.of<AuthenticationBloc>(context)
                  .currentUser
                  .profile
                  .displayName)
            .build()));
  }

  void _toggleTimer() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      setState(() {
        _details.time.currentOffsetInternal = stopwatch.elapsed.inMilliseconds;
        _details.time.currentPeriodStartInternal = null;
      });
    } else {
      // Initialize with the duration out of the detail first.
      stopwatch.start();
      setState(() {
        _details.time.currentPeriodStartInternal =
            TZDateTime.now(local).millisecondsSinceEpoch;
      });
    }
    widget.game.add(SingleGameUpdateResult(result: _details.build()));
  }

  void _resetTimer() async {
    var ret = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Messages.of(context).resettimer),
            content: Text(Messages.of(context).resettimerbody),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              )
            ],
          );
        });
    if (ret != null && ret == true) {
      stopwatch.reset();
      if (stopwatch.isRunning) {
        setState(() {
          _details.time.currentPeriodStartInternal =
              DateTime.now().millisecondsSinceEpoch;
          _details.time.currentOffsetInternal = 0;
        });
      } else {
        setState(() {
          _details.time.currentOffsetInternal = 0;
        });
      }
      widget.game.add(SingleGameUpdateResult(result: _details.build()));
    }
  }

  void _timerSettings() async {
    var time = await timerSetupDialog(context, _details.build());
    if (time != null) {
      setState(() {
        _details.time = time.toBuilder();
      });

      widget.game.add(SingleGameUpdateResult(result: _details.build()));
    }
  }

  void _changeResult() async {
    // Do something to change the result.
    var details = await changeScoreDialog(context, _details.build());
    if (details != null) {
      widget.game.add(SingleGameUpdateResult(result: details.build()));
      _writeLog(GameLogType.UpdateScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: widget.game,
      listener: (context, state) {
        if (state is SingleGameDeleted) {
          // Go back where we came from.
          Navigator.pop(context);
        } else if (state.game != _lastGame) {
          _updateGame(state.game);
        }
      },
      child: BlocBuilder(
        cubit: widget.game,
        builder: (context, state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    if (_details.inProgress == GameInProgress.NotStarted) {
      return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    child: RaisedButton(
                      onPressed: _startGame,
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: Text(Messages.of(context).startgame),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    } else if (_details.inProgress == GameInProgress.Final) {
      String resultStr;
      var color = Colors.black;
      switch (_details.result) {
        case GameResult.Loss:
          resultStr = Messages.of(context).resultLoss(_details.build());
          color = Theme.of(context).errorColor;
          break;
        case GameResult.Tie:
          resultStr = Messages.of(context).resultTie(_details.build());
          break;
        case GameResult.Win:
          resultStr = Messages.of(context).resultWin(_details.build());
          break;
        default:
          resultStr = Messages.of(context).gameresult(_details.result);
          break;
      }
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10.0),
            Text(
              resultStr,
              style:
                  Theme.of(context).textTheme.headline6.copyWith(color: color),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    child: RaisedButton(
                      onPressed: _changeResult,
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: Text("Change score"),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    } else {
      var children = <Widget>[
        PeriodSelector(
          currentPeriod: _details.currentPeriod.build(),
          divisionsType: _details.divisons,
          team: widget.team,
          onChanged: _periodChanged,
        )
      ];
      if (MediaQuery.of(context).viewInsets.bottom == 0.0) {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(),
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        Messages.of(context).forpts,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor,
                            ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerLeft,
                            tileMode: TileMode.mirror,
                            colors: <Color>[Colors.grey.shade300, Colors.white],
                          ),
                        ),
                        child: NumberPicker.integer(
                          key: _ptsForState,
                          listViewWidth: 80.0,
                          itemExtent: 40.0,
                          disabled:
                              _details.inProgress == GameInProgress.NotStarted,
                          initialValue:
                              _currentPeriodResults.score.ptsFor.toInt(),
                          minValue: 0,
                          maxValue: 10000,
                          onChanged: (val) {
                            _ptsFor = val;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(),
                  margin: EdgeInsets.only(bottom: 5.0, top: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: _resetTimer,
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: _timerSettings,
                          ),
                        ],
                      ),
                      Container(
                        child: StopwatchDisplay(
                          stopwatch: stopwatch,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontSize: 25.0),
                        ),
                      ),
                      IconButton(
                        icon: stopwatch.isRunning
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.play_arrow),
                        onPressed: _toggleTimer,
                        iconSize: 40.0,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(),
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Messages.of(context).againstpts,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor,
                            ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerLeft,
                            tileMode: TileMode.mirror,
                            colors: <Color>[Colors.grey.shade300, Colors.white],
                          ),
                        ),
                        child: NumberPicker.integer(
                          listViewWidth: 80.0,
                          itemExtent: 40.0,
                          key: _ptsAgainstState,
                          disabled:
                              _details.inProgress == GameInProgress.NotStarted,
                          initialValue:
                              _currentPeriodResults.score.ptsAgainst.toInt(),
                          minValue: 0,
                          maxValue: 10000,
                          onChanged: (val) {
                            _ptsAgainst = val;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        children.add(
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                  child: RaisedButton(
                    onPressed: _updateScore,
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text(Messages.of(context).updatescorebutton),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
                child: RaisedButton(
                  onPressed: _finishGame,
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  child: Text(Messages.of(context).finishgamebutton),
                ),
              ),
            ],
          ),
        );
      }
      return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    }
  }
}
