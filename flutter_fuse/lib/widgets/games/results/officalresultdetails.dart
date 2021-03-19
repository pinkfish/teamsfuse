import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/blocs.dart';
import '../../../services/messages.dart';
import '../../blocs/singlesharedgameprovider.dart';

///
/// The state of the detail for the offical results.
///
enum DetailsState {
  /// The game has not started.
  notStarted,

  /// Game is in progress.
  inProgress,

  /// Final score has been entered.
  finalState,
}

///
/// No logs in an offical result display.  Just set the
/// values on a per period basis.
///
class OfficalScoreDetails extends StatefulWidget {
  /// Constructor.
  OfficalScoreDetails(this.game);

  /// The game to show the offical results for.
  final GameSharedData game;

  @override
  State createState() {
    return _OfficalScoreDetailsState();
  }
}

class _OfficalScoreDetailsState extends State<OfficalScoreDetails> {
  GameOfficialResultsBuilder _results;
  DetailsState _currentState;
  bool _startedAsFinal = false;
  TextEditingController _regulationHomePts;
  TextEditingController _regulationAwayPts;
  TextEditingController _overtimeHomePts;
  TextEditingController _overtimeAwayPts;
  TextEditingController _penaltyHomePts;
  TextEditingController _penaltyAwayPts;
  bool _overtimePeriod = false;
  bool _penaltyPeriod = false;

  @override
  void initState() {
    super.initState();
    // Make our own copy of it.
    _results = widget.game.officialResult.toBuilder();
    if (_results.result == OfficialResult.NotStarted) {
      _currentState = DetailsState.notStarted;
    } else if (_results.result == OfficialResult.InProgress) {
      _currentState = DetailsState.inProgress;
    } else {
      _currentState = DetailsState.finalState;
      _startedAsFinal = true;
    }

    if (widget.game.officialResult.scores.containsKey(GamePeriod.regulation1)) {
      _regulationHomePts = TextEditingController(
          text: _results
              .scoresInternal[GamePeriod.regulation1.toIndex()].score.ptsFor
              .toString());
      _regulationAwayPts = TextEditingController(
          text: _results
              .scoresInternal[GamePeriod.regulation1.toIndex()].score.ptsAgainst
              .toString());
    }

    _overtimePeriod =
        widget.game.officialResult.scores.containsKey(GamePeriod.overtime1);
    if (_overtimePeriod) {
      _overtimeHomePts = TextEditingController(
          text: _results
              .scoresInternal[GamePeriod.overtime1.toIndex()].score.ptsFor
              .toString());
      _overtimeAwayPts = TextEditingController(
          text: _results
              .scoresInternal[GamePeriod.overtime1.toIndex()].score.ptsAgainst
              .toString());
    }
    _penaltyPeriod =
        widget.game.officialResult.scores.containsKey(GamePeriod.penalty);
    if (_penaltyPeriod) {
      _penaltyHomePts = TextEditingController(
          text: _results
              .scoresInternal[GamePeriod.penalty.toIndex()].score.ptsFor
              .toString());
      _penaltyAwayPts = TextEditingController(
          text: _results
              .scoresInternal[GamePeriod.penalty.toIndex()].score.ptsAgainst
              .toString());
    }
  }

  void _updateGame(SingleSharedGameBloc bloc) async {
    _setupWinLossTie();
    if (_currentState == DetailsState.finalState) {
      // Show dialogs and stuff.
      _finishGame(bloc);
    } else {
      bloc.add(SingleSharedGameUpdateOfficalResult(result: _results.build()));
    }
  }

  void _setupWinLossTie() {
    // Writes out the data too.
    if (!_results.scoresInternal
        .build()
        .containsKey(GamePeriod.regulation1.toIndex())) {
      var scoreBuilder = GameScoreBuilder()
        ..ptsFor = int.parse(_regulationHomePts.value.toString())
        ..ptsAgainst = int.parse(_regulationAwayPts.text.toString());
      _results.scoresInternal[GamePeriod.regulation1.toIndex()] =
          (GameResultPerPeriodBuilder()
                ..period = GamePeriod.regulation1.toBuilder()
                ..score = scoreBuilder)
              .build();
    } else {
      var scoreBuilder = GameScoreBuilder()
        ..ptsFor = int.parse(_regulationHomePts.text.toString())
        ..ptsAgainst = int.parse(_regulationAwayPts.text.toString());
      _results.scoresInternal[GamePeriod.regulation1.toIndex()] = _results
          .scoresInternal[GamePeriod.regulation1.toIndex()]
          .rebuild((b) => b..score = scoreBuilder);
    }

    if (_results.scoresInternal
        .build()
        .containsKey(GamePeriod.overtime1.toIndex())) {
      if (!_overtimePeriod) {
        // Remove it.
        _results.scoresInternal.remove(GamePeriod.overtime1.toIndex());
      } else {
        var scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_overtimeHomePts.text.toString())
          ..ptsAgainst = int.parse(_overtimeAwayPts.text.toString());
        _results.scoresInternal[GamePeriod.overtime1.toIndex()] = _results
            .scoresInternal[GamePeriod.overtime1.toIndex()]
            .rebuild((b) => b..score = scoreBuilder);
      }
    } else {
      if (_overtimePeriod) {
        var scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_overtimeHomePts.text.toString())
          ..ptsAgainst = int.parse(_overtimeAwayPts.text.toString());

        _results.scoresInternal[GamePeriod.overtime1.toIndex()] =
            (GameResultPerPeriodBuilder()
                  ..period = GamePeriod.overtime1.toBuilder()
                  ..score = scoreBuilder)
                .build();
      }
    }

    if (_results.scoresInternal
        .build()
        .containsKey(GamePeriod.penalty.toIndex())) {
      if (!_penaltyPeriod) {
        // Remove it.
        _results.scoresInternal.remove(GamePeriod.penalty.toIndex());
      } else {
        var scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_penaltyHomePts.text.toString())
          ..ptsAgainst = int.parse(_penaltyAwayPts.text.toString());
        _results.scoresInternal[GamePeriod.overtime1.toIndex()] = _results
            .scoresInternal[GamePeriod.overtime1.toIndex()]
            .rebuild((b) => b..score = scoreBuilder);
      }
    } else {
      if (_penaltyPeriod) {
        var scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_penaltyHomePts.text.toString())
          ..ptsAgainst = int.parse(_penaltyAwayPts.text.toString());
        _results.scoresInternal[GamePeriod.penalty.toIndex()] =
            (GameResultPerPeriodBuilder()
                  ..period = GamePeriod.penalty.toBuilder()
                  ..score = scoreBuilder)
                .build();
      }
    }

    if (_currentState == DetailsState.notStarted) {
      _results.result = OfficialResult.NotStarted;
    } else if (_currentState == DetailsState.inProgress) {
      _results.result = OfficialResult.InProgress;
    } else {
      var gameResult = OfficialResult.Tie;
      for (var p in _results.scoresInternal.build().values) {
        // Lets see if we can get the right result out of here.
        if (p.score.ptsFor > p.score.ptsAgainst) {
          gameResult = OfficialResult.HomeTeamWon;
        }
        if (p.score.ptsAgainst > p.score.ptsFor) {
          gameResult = OfficialResult.AwayTeamWon;
        }
      }
      _results.result = gameResult;
    }
  }

  void _finishGame(SingleSharedGameBloc bloc) async {
    // Finalize game?
    _setupWinLossTie();

    bool ret;
    if (!_startedAsFinal) {
      ret = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(Messages.of(context).finalscore),
              content: Text(
                  Messages.of(context).finalOfficalScoreBody(_results.build())),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child:
                      Text(MaterialLocalizations.of(context).cancelButtonLabel),
                )
              ],
            );
          });
    } else {
      // Already final, so just update it to the result.
      ret = true;
    }
    if (ret != null && ret == true) {
      // Save the state update.
      setState(() {});

      // Save the game and exit.
      bloc.add(SingleSharedGameUpdateOfficalResult(result: _results.build()));
    }
  }

  void _updateState(DetailsState state) {
    setState(() {
      _currentState = state;
    });
    // Work out the current win/loss/tie state.
    _setupWinLossTie();
  }

  Widget _buildFinalText(TextStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15.0, right: 5.0),
          child: Text(
            Messages.of(context).finalscore,
            style: style,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0, left: 25.0, right: 5.0),
          child: Text(
            Messages.of(context).finalOfficalScoreBody(_results.build()),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    );
  }

  void _doStuff(VoidCallback fn) {
    setState(fn);
    _setupWinLossTie();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var header = theme.textTheme.subtitle1.copyWith(
        color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.w500);

    return SingleSharedGameProvider(
      sharedGameUid: widget.game.uid,
      builder: (context, bloc) => BlocListener(
        bloc: bloc,
        listener: (contect, state) {
          if (state is SingleSharedGameDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          bloc: bloc,
          builder: (context, state) {
            if (state is SingleSharedGameDeleted) {
              return Center(child: Text(Messages.of(context).nogames));
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              Messages.of(context).startgame,
                              style: header,
                            ),
                          ),
                          RadioListTile<DetailsState>(
                            groupValue: _currentState,
                            value: DetailsState.notStarted,
                            title: Text(Messages.of(context)
                                .gameofficalinprogress(
                                    OfficialResult.NotStarted)),
                            onChanged: _updateState,
                          ),
                          RadioListTile<DetailsState>(
                            groupValue: _currentState,
                            value: DetailsState.inProgress,
                            title: Text(Messages.of(context)
                                .gameofficalinprogress(
                                    OfficialResult.InProgress)),
                            onChanged: _updateState,
                          ),
                          RadioListTile<DetailsState>(
                            groupValue: _currentState,
                            value: DetailsState.finalState,
                            title: Text(Messages.of(context).finalscore),
                            onChanged: _updateState,
                          ),
                          _currentState == DetailsState.finalState
                              ? Divider()
                              : SizedBox(
                                  height: 0.0,
                                ),
                          _currentState == DetailsState.finalState
                              ? _buildFinalText(header)
                              : SizedBox(
                                  height: 0.0,
                                ),
                          Divider(),
                          Container(
                            margin: EdgeInsets.only(left: 15.0, right: 5.0),
                            child: Text(
                              Messages.of(context).periodNameRegulation,
                              style: header,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 25.0, right: 15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: Messages.of(context).home,
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _regulationHomePts,
                                    onChanged: (str) => _doStuff(() => false),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: Messages.of(context).away,
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: _regulationAwayPts,
                                    onChanged: (str) => _doStuff(() => false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          CheckboxListTile(
                            value: _overtimePeriod,
                            onChanged: (val) =>
                                setState(() => _overtimePeriod = val),
                            title: Text(
                              Messages.of(context).periodNameOvertime,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 25.0, right: 15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: Messages.of(context).home,
                                    ),
                                    keyboardType: TextInputType.number,
                                    enabled: _overtimePeriod,
                                    controller: _overtimeAwayPts,
                                    onChanged: (str) => _doStuff(() => false),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: Messages.of(context).away,
                                    ),
                                    enabled: _overtimePeriod,
                                    controller: _overtimeAwayPts,
                                    keyboardType: TextInputType.number,
                                    onChanged: (str) => _doStuff(() => false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          CheckboxListTile(
                            value: _penaltyPeriod,
                            onChanged: (val) =>
                                setState(() => _penaltyPeriod = val),
                            title: Text(Messages.of(context).penalty),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 25.0, right: 15.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: Messages.of(context).home,
                                    ),
                                    keyboardType: TextInputType.number,
                                    enabled: _penaltyPeriod,
                                    controller: _penaltyHomePts,
                                    onChanged: (str) => _doStuff(() => false),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: Messages.of(context).away,
                                    ),
                                    enabled: _penaltyPeriod,
                                    keyboardType: TextInputType.number,
                                    controller: _penaltyAwayPts,
                                    onChanged: (str) => _doStuff(() => false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => _updateGame(bloc),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      child: Text(Messages.of(context).saveButtonText),
                    ),
                    FlatButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel),
                    )
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
