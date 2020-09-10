import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../blocs/singlesharedgameprovider.dart';

enum DetailsState { notStarted, inProgress, finalState }

///
/// No logs in an offical result display.  Just set the
/// values on a per period basis.
///
class OfficalScoreDetails extends StatefulWidget {
  OfficalScoreDetails(this.game);

  final GameSharedData game;

  @override
  State createState() {
    return new _OfficalScoreDetailsState();
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
    print('init this state');
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

    if (widget.game.officialResult.scores.containsKey(GamePeriod.regulation)) {
      _regulationHomePts = TextEditingController(
          text: _results.scores[GamePeriod.regulation].score.ptsFor.toString());
      _regulationAwayPts = TextEditingController(
          text: _results.scores[GamePeriod.regulation].score.ptsAgainst
              .toString());
    }

    _overtimePeriod =
        widget.game.officialResult.scores.containsKey(GamePeriod.overtime);
    if (_overtimePeriod) {
      _overtimeHomePts = TextEditingController(
          text: _results.scores[GamePeriod.overtime].score.ptsFor.toString());
      _overtimeAwayPts = TextEditingController(
          text:
              _results.scores[GamePeriod.overtime].score.ptsAgainst.toString());
    }
    _penaltyPeriod =
        widget.game.officialResult.scores.containsKey(GamePeriod.penalty);
    if (_penaltyPeriod) {
      _penaltyHomePts = TextEditingController(
          text: _results.scores[GamePeriod.penalty].score.ptsFor.toString());
      _penaltyAwayPts = TextEditingController(
          text:
              _results.scores[GamePeriod.penalty].score.ptsAgainst.toString());
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
    if (!_results.scores.build().containsKey(GamePeriod.regulation)) {
      GameScoreBuilder scoreBuilder = GameScoreBuilder()
        ..ptsFor = int.parse(_regulationHomePts.value.toString())
        ..ptsAgainst = int.parse(_regulationAwayPts.text.toString());
      _results.scores[GamePeriod.regulation] = (GameResultPerPeriodBuilder()
            ..period = GamePeriod.regulation.toBuilder()
            ..score = scoreBuilder)
          .build();
    } else {
      print('froggy ${_regulationAwayPts.text}');
      GameScoreBuilder scoreBuilder = GameScoreBuilder()
        ..ptsFor = int.parse(_regulationHomePts.text.toString())
        ..ptsAgainst = int.parse(_regulationAwayPts.text.toString());
      _results.scores[GamePeriod.regulation] = _results
          .scores[GamePeriod.regulation]
          .rebuild((b) => b..score = scoreBuilder);
    }

    if (_results.scores.build().containsKey(GamePeriod.overtime)) {
      if (!_overtimePeriod) {
        // Remove it.
        _results.scores.remove(GamePeriod.overtime);
      } else {
        GameScoreBuilder scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_overtimeHomePts.text.toString())
          ..ptsAgainst = int.parse(_overtimeAwayPts.text.toString());
        _results.scores[GamePeriod.overtime] = _results
            .scores[GamePeriod.overtime]
            .rebuild((b) => b..score = scoreBuilder);
      }
    } else {
      if (_overtimePeriod) {
        GameScoreBuilder scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_overtimeHomePts.text.toString())
          ..ptsAgainst = int.parse(_overtimeAwayPts.text.toString());

        _results.scores[GamePeriod.overtime] = (GameResultPerPeriodBuilder()
              ..period = GamePeriod.overtime.toBuilder()
              ..score = scoreBuilder)
            .build();
      }
    }

    if (_results.scores.build().containsKey(GamePeriod.penalty)) {
      if (!_penaltyPeriod) {
        // Remove it.
        _results.scores.remove(GamePeriod.penalty);
      } else {
        GameScoreBuilder scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_penaltyHomePts.text.toString())
          ..ptsAgainst = int.parse(_penaltyAwayPts.text.toString());
        _results.scores[GamePeriod.overtime] = _results
            .scores[GamePeriod.overtime]
            .rebuild((b) => b..score = scoreBuilder);
      }
    } else {
      if (_penaltyPeriod) {
        GameScoreBuilder scoreBuilder = GameScoreBuilder()
          ..ptsFor = int.parse(_penaltyHomePts.text.toString())
          ..ptsAgainst = int.parse(_penaltyAwayPts.text.toString());
        _results.scores[GamePeriod.penalty] = (GameResultPerPeriodBuilder()
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
      OfficialResult gameResult = OfficialResult.Tie;
      for (GameResultPerPeriod p in _results.scores.build().values) {
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
          builder: (BuildContext context) {
            return new AlertDialog(
              title: new Text(Messages.of(context).finalscore),
              content: new Text(
                  Messages.of(context).finalofficalscorebody(_results.build())),
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
    } else {
      // Already final, so just update it to the new result.
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
            Messages.of(context).finalofficalscorebody(_results.build()),
            style: Theme.of(context).textTheme.subhead,
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
    ThemeData theme = Theme.of(context);

    print("Stuff in here ${_results.result}");
    TextStyle header = theme.textTheme.subhead.copyWith(
        color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.w500);

    return SingleSharedGameProvider(
      sharedGameUid: widget.game.uid,
      builder: (BuildContext context, SingleSharedGameBloc bloc) =>
          BlocListener(
        cubit: bloc,
        listener: (BuildContext contect, SingleSharedGameState state) {
          if (state is SingleSharedGameDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: bloc,
          builder: (BuildContext context, SingleSharedGameState state) {
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
                              Messages.of(context).regulationperiod,
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
                                    onChanged: (String str) =>
                                        _doStuff(() => false),
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
                                    onChanged: (String str) =>
                                        _doStuff(() => false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          CheckboxListTile(
                            value: _overtimePeriod,
                            onChanged: (bool val) =>
                                setState(() => _overtimePeriod = val),
                            title: Text(
                              Messages.of(context).overtimeperiod,
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
                                    onChanged: (String str) =>
                                        _doStuff(() => false),
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
                                    onChanged: (String str) =>
                                        _doStuff(() => false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          CheckboxListTile(
                            value: _penaltyPeriod,
                            onChanged: (bool val) =>
                                setState(() => _penaltyPeriod = val),
                            title: Text(Messages.of(context).penaltyperiod),
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
                                    onChanged: (String str) =>
                                        _doStuff(() => false),
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
                                    onChanged: (String str) =>
                                        _doStuff(() => false),
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
                      child: Text(Messages.of(context).savebuttontext),
                      onPressed: () => _updateGame(bloc),
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                    ),
                    FlatButton(
                      child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel),
                      onPressed: () => Navigator.pop(context, false),
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
