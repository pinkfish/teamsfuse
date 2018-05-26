import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/util/numberpicker.dart';
import 'package:flutter_fuse/util/debouncer.dart';
import 'package:flutter_fuse/widgets/util/stopwatchdisplay.dart';
import 'package:timezone/timezone.dart';
import 'dart:async';
import 'periodselector.dart';

class ScoreDetails extends StatefulWidget {
  final Game game;
  final Team team;

  ScoreDetails(this.game, this.team);

  @override
  State createState() {
    return new _ScoreDetailsState();
  }
}

class _ScoreDetailsState extends State<ScoreDetails> {
  MyStopwatch stopwatch = new MyStopwatch();
  StreamSubscription<UpdateReason> _gameSubscription;
  GameResultPerPeriod _currentPeriodResults;
  GameResultDetails _details;
  int _ptsFor;
  int _ptsAgainst;
  Debouncer<bool> _debouncer;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<NumberPickerState> _ptsForState =
      new GlobalKey<NumberPickerState>();
  ScrollController _scrollController;
  GlobalKey<NumberPickerState> _ptsAgainstState =
      new GlobalKey<NumberPickerState>();

  @override
  void initState() {
    super.initState();
    _details = new GameResultDetails.copy(widget.game.result);
    if (widget.game.result.currentPeriod != null) {
      _currentPeriodResults =
          widget.game.result.scores[widget.game.result.currentPeriod];
    }
    if (_currentPeriodResults == null) {
      _currentPeriodResults = new GameResultPerPeriod(
          period:
              new GamePeriod(type: GamePeriodType.Regulation, periodNumber: 1),
          score: new GameScore(ptsAgainst: 0, ptsFor: 0));
    }
    if (_details.currentPeriod == null) {
      _details.currentPeriod = _currentPeriodResults.period;
    }
    _debouncer = new Debouncer<bool>(new Duration(minutes: 2), _sendUpdate,
        resetOnAdd: false);
    _ptsFor = _currentPeriodResults.score.ptsFor;
    _ptsAgainst = _currentPeriodResults.score.ptsAgainst;
    widget.game.loadGameLogs();
    // Setup the stop watch/
    stopwatch.resetTo(_details.currentStopwatch().inMilliseconds);
    print("${_details.currentOffset} ${_details.currentPeriodStart}");
    if (_details.currentPeriodStart != null) {
      stopwatch.start();
    }
    _gameSubscription = widget.game.thisGameStream.listen(_updateGame);
    _scrollController = new ScrollController(
        initialScrollOffset: PeriodNumberSelector.ITEM_EXTENT *
            (_details.currentPeriod.periodNumber - 1) *
            2);
  }

  @override
  void dispose() {
    super.dispose();
    _gameSubscription?.cancel();
    _gameSubscription = null;
  }

  void _updateGame(UpdateReason reason) {
    // Change scores and timers.
    GamePeriod period = new GamePeriod(
        type: widget.game.result.currentPeriod.type, periodNumber: 1);
    if (widget.game.result.scores.containsKey(period)) {
      _ptsForState.currentState
          .animateInt(widget.game.result.scores[period].score.ptsFor);
      _ptsAgainstState.currentState
          .animateInt(widget.game.result.scores[period].score.ptsFor);
    }

    // If the period changed, update stuff.
    if (!widget.game.result.currentPeriod.isEqualTo(_details.currentPeriod)) {
      _periodChanged(widget.game.result.currentPeriod);
    }

    setState(() {
      print("$period ${widget.game.result.scores}");
      if (widget.game.result.scores.containsKey(period)) {
        _currentPeriodResults.period = widget.game.result.scores[period].period;
      }
      _details.currentPeriod = widget.game.result.currentPeriod;
    });
  }

  void _periodChanged(GamePeriod newPeriod) {
    if (newPeriod.type != _currentPeriodResults.period.type) {
      _setPeriodType(newPeriod);
    }
    _currentPeriodResults.period = newPeriod;
    _details.currentPeriod = newPeriod;
    _writeLog(GameLogType.PeriodStart);
    widget.game.updateFirestoreResult(_details);
  }

  void _setPeriodType(GamePeriod newPeriod) {
    GamePeriod scoreUpdate = new GamePeriod(
        type: _currentPeriodResults.period.type, periodNumber: 0);
    _details.scores[scoreUpdate] = _currentPeriodResults;
    // Create a new score type.
    GamePeriod newScoreUpdate =
        new GamePeriod(type: newPeriod.type, periodNumber: 0);
    if (!_details.scores.containsKey(newScoreUpdate)) {
      _details.scores[newScoreUpdate] = new GameResultPerPeriod(
        period: newScoreUpdate,
        score: new GameScore(ptsFor: 0, ptsAgainst: 0),
      );
    }
    setState(() {
      _currentPeriodResults.period = newPeriod;
    });
  }

  void _sendUpdate(List<bool> results) {
    widget.game.updateFirestoreResult(_details);
  }

  void _updateScore() async {
    setState(() {
      if (_ptsAgainst != null) {
        _currentPeriodResults.score.ptsAgainst = _ptsAgainst;
      }
      if (_ptsFor != null) {
        _currentPeriodResults.score.ptsFor = _ptsFor;
      }
      print("Update score $_currentPeriodResults");
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
    bool ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(Messages.of(context).finalscore),
            content: new Text(Messages.of(context).finalscorebody(
                _currentPeriodResults.score.ptsFor,
                _currentPeriodResults.score.ptsAgainst,
                gameResult.toString())),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
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
        _currentPeriodResults.period =
            new GamePeriod(type: GamePeriodType.Regulation);
        _details.scores[_currentPeriodResults.period] = _currentPeriodResults;
        _details.inProgress = GameInProgress.Final;
        _details.result = gameResult;
        _writeLog(GameLogType.PeriodStop);
      });
      // Save the game and exit.
      widget.game.updateFirestoreResult(_details);
      Navigator.pop(context);
    }
  }

  Future<void> _startGame() async {
    if (widget.team.sport == Sport.Soccer) {
      return _startGameSimple();
    }
    // Ask if they are sure
    GameDivisionsType ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text(Messages.of(context).startgame),
            children: <Widget>[
              new Text(Messages.of(context).startgamebody),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, GameDivisionsType.Halves);
                },
                child: const Text('Halves'),
              ),
              new SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, GameDivisionsType.Thirds);
                },
                child: const Text('Thirds'),
              ),
              new SimpleDialogOption(
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
        _details.divisions = ret;
        _details.inProgress = GameInProgress.InProgress;
        _details.currentPeriodStart = new TZDateTime.now(local);
        _details.currentOffset = new Duration();
        _details.currentPeriod =
            new GamePeriod(type: GamePeriodType.Regulation, periodNumber: 1);
        _writeLog(GameLogType.PeriodStart);
        widget.game.updateFirestoreResult(_details);
      });
    }
  }

  Future<void> _startGameSimple() async {
    // Ask if they are sure
    bool ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(Messages.of(context).startgame),
            content: new Text(Messages.of(context).startgamebody),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
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
        _details.divisions = GameDivisionsType.Halves;
        _details.inProgress = GameInProgress.InProgress;
        _details.currentPeriodStart = new TZDateTime.now(local);
        _details.currentOffset = new Duration();
        _details.currentPeriod =
            new GamePeriod(type: GamePeriodType.Regulation, periodNumber: 1);
        _writeLog(GameLogType.PeriodStart);
        widget.game.updateFirestoreResult(_details);
      });
    }
  }

  void _writeLog(GameLogType type, {String message}) {
    widget.game.addGameLog(new GameLog(
        type: type,
        message: message,
        score: _currentPeriodResults.score,
        period: _currentPeriodResults.period,
        eventTime: new DateTime.now().millisecondsSinceEpoch,
        uid: UserDatabaseData.instance.userUid,
        displayName: UserDatabaseData.instance.mePlayer.name));
  }

  void _toggleTimer() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      setState(() {
        _details.currentOffset = stopwatch.elapsed;
        _details.currentPeriodStart = null;
      });
    } else {
      // Initialize with the duration out of the detail first.
      stopwatch.start();
      setState(() {
        _details.currentPeriodStart = new TZDateTime.now(local);
      });
    }
    print("Update result $_details");
    widget.game.updateFirestoreResult(_details);
  }

  void _resetTimer() async {
    bool ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(Messages.of(context).resettimer),
            content: new Text(Messages.of(context).resettimerbody),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
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
          _details.currentPeriodStart = new TZDateTime.now(local);
          _details.currentOffset = new Duration(milliseconds: 0);
        });
      } else {
        setState(() {
          _details.currentOffset = new Duration(milliseconds: 0);
        });
      }
      widget.game.updateFirestoreResult(_details);
    }
  }

  void _timerSettings() {}

  void _changeResult() {
    // Do something to change the result.
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (_details.inProgress == GameInProgress.NotStarted) {
      return new Form(
        key: _formKey,
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Container(
                    margin: new EdgeInsets.all(5.0),
                    child: new RaisedButton(
                      onPressed: _startGame,
                      color: theme.accentColor,
                      textColor: Colors.white,
                      child: new Text("Start Game"),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    } else if (_details.inProgress == GameInProgress.Final) {
      return new Form(
        key: _formKey,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Text(Messages.of(context).gameresult(_details.result)),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Container(
                    margin: new EdgeInsets.all(5.0),
                    child: new RaisedButton(
                      onPressed: _changeResult,
                      color: theme.accentColor,
                      textColor: Colors.white,
                      child: new Text("Change score"),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    } else {
      List<Widget> children = [
        /*
        new PeriodNumberSelector(
            _details.currentPeriod, _details.divisions, _periodChanged, _scrollController),
        new PeriodTypeSelector(
            widget.team, _details.currentPeriod, _periodChanged),
            */
        new PeriodSelector(
          currentPeriod: _details.currentPeriod,
          divisionsType: _details.divisions,
          team: widget.team,
          onChanged: _periodChanged,
        )
      ];
      if (MediaQuery.of(context).viewInsets.bottom == 0.0) {
        children.add(
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                flex: 1,
                child: new Container(
                  decoration: new BoxDecoration(),
                  margin: new EdgeInsets.only(bottom: 5.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new Text(
                        Messages.of(context).forpts,
                        style: theme.textTheme.subhead.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                        ),
                      ),
                      new Container(
                        decoration: new BoxDecoration(
                          border: new Border.all(
                              color: theme.dividerColor, width: 1.0),
                          gradient: new LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerLeft,
                            tileMode: TileMode.mirror,
                            colors: [Colors.grey.shade300, Colors.white],
                          ),
                        ),
                        child: new NumberPicker.integer(
                          key: _ptsForState,
                          listViewWidth: 80.0,
                          itemExtent: 40.0,
                          disabled:
                              _details.inProgress == GameInProgress.NotStarted,
                          initialValue: _currentPeriodResults.score.ptsFor,
                          minValue: 0,
                          maxValue: 10000,
                          onChanged: (num val) {
                            _ptsFor = val;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Expanded(
                flex: 1,
                child: new Container(
                  decoration: new BoxDecoration(),
                  margin: new EdgeInsets.only(bottom: 5.0, top: 5.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: _resetTimer,
                          ),
                          new IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: _timerSettings,
                          ),
                        ],
                      ),
                      new Container(
                        child: new StopwatchDisplay(
                          stopwatch: stopwatch,
                          style: Theme
                              .of(context)
                              .textTheme
                              .title
                              .copyWith(fontSize: 25.0),
                        ),
                      ),
                      new IconButton(
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
              new Expanded(
                flex: 1,
                child: new Container(
                  decoration: new BoxDecoration(),
                  margin: new EdgeInsets.only(bottom: 5.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        Messages.of(context).againstpts,
                        style: theme.textTheme.subhead.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.accentColor,
                        ),
                      ),
                      new Container(
                        decoration: new BoxDecoration(
                          border: new Border.all(
                              color: theme.dividerColor, width: 1.0),
                          gradient: new LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerLeft,
                            tileMode: TileMode.mirror,
                            colors: [Colors.grey.shade300, Colors.white],
                          ),
                        ),
                        child: new NumberPicker.integer(
                          listViewWidth: 80.0,
                          itemExtent: 40.0,
                          key: _ptsAgainstState,
                          disabled:
                              _details.inProgress == GameInProgress.NotStarted,
                          initialValue: _currentPeriodResults.score.ptsAgainst,
                          minValue: 0,
                          maxValue: 10000,
                          onChanged: (num val) {
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
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Container(
                  margin:
                      new EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                  child: new RaisedButton(
                    onPressed: _updateScore,
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: new Text(Messages.of(context).updatescorebutton),
                  ),
                ),
              ),
              new Container(
                margin: new EdgeInsets.only(right: 5.0, bottom: 5.0),
                child: new RaisedButton(
                  onPressed: _finishGame,
                  color: theme.accentColor,
                  textColor: Colors.white,
                  child: new Text(Messages.of(context).finishgamebutton),
                ),
              ),
            ],
          ),
        );
      }
      return new Form(
        key: _formKey,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    }
  }
}
