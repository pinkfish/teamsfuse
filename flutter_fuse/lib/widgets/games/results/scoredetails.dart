import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/blocs.dart';
import '../../../services/messages.dart';
import '../..//util/numberpicker.dart';

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
  GameResultPerPeriodBuilder _currentPeriodResults;
  GameResultDetailsBuilder _details;
  num _ptsFor;
  num _ptsAgainst;

  @override
  void initState() {
    super.initState();
    _details = widget.game.state.game.result.toBuilder();
    _details.currentPeriod = GamePeriod.regulation1.toBuilder();
    if (widget.game.state.game.result.scores
        .containsKey(_details.currentPeriod)) {
      _currentPeriodResults = widget
          .game.state.game.result.scores[_details.currentPeriod]
          .toBuilder();
      _currentPeriodResults.score.intermediate = false;
    } else {
      // Default score bits.
      _currentPeriodResults = GameResultPerPeriodBuilder()
        ..period = _details.currentPeriod
        ..score.ptsFor = 0
        ..score.ptsAgainst = 0
        ..score.intermediate = false;
    }
    _ptsFor = _currentPeriodResults.score.ptsFor;
    _ptsAgainst = _currentPeriodResults.score.ptsAgainst;
  }

  void _sendUpdate() {
    final newData = _details.build().rebuild((b) => b
      ..currentPeriod = GamePeriod.finalPeriod.toBuilder()
      ..inProgress = GameInProgress.Final);
    widget.game.add(SingleGameUpdateResult(result: newData));
  }

  void _updateScore() async {
    _sendUpdate();
    setState(() {
      if (_ptsAgainst != null) {
        _currentPeriodResults.score.ptsAgainst = _ptsAgainst;
      }
      if (_ptsFor != null) {
        _currentPeriodResults.score.ptsFor = _ptsFor;
      }
      _details.scoresInternal[_currentPeriodResults.period.build()] =
          _currentPeriodResults.build();
      var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
      undoBloc.addEvent(
          (GameEventBuilder()
                ..type = GameEventType.ScoreSet
                ..fixedScore = _currentPeriodResults.score
                ..period = GamePeriod.regulation1.toBuilder()
                ..timestamp = clock.now().toUtc()
                ..points = 0
                ..opponent = false
                ..gameUid = widget.game.gameUid
                ..uid =
                    BlocProvider.of<AuthenticationBloc>(context).currentUser.uid
                ..playerUid = BlocProvider.of<PlayerBloc>(context).state.me.uid)
              .build(),
          false);
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: widget.game,
      listener: (context, state) {
        if (state is SingleGameDeleted) {
          // Go back where we came from.
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
        bloc: widget.game,
        builder: (context, state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return _buildForm();
        },
      ),
    );
  }

  Widget _finalScoreBits() {
    String resultStr;
    var color = Colors.black;
    _currentPeriodResults.score.ptsFor = _ptsFor;
    _currentPeriodResults.score.ptsAgainst = _ptsAgainst;
    _details.scoresInternal[_currentPeriodResults.period.build()] =
        _currentPeriodResults.build();
    if (_ptsFor > _ptsAgainst) {
      resultStr = Messages.of(context).win;
      _details.result = GameResult.Win;
    } else if (_ptsAgainst > _ptsFor) {
      resultStr = Messages.of(context).loss;
      color = Theme.of(context).errorColor;
      _details.result = GameResult.Loss;
    } else {
      resultStr = Messages.of(context).tie;
      _details.result = GameResult.Tie;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10.0),
        Text(
          resultStr,
          style: Theme.of(context).textTheme.headline6.copyWith(color: color),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Column(
              children: [
                Text(Messages.of(context).forPointsAbbreviation,
                    style: Theme.of(context).textTheme.subtitle1),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).dividerColor, width: 1.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerLeft,
                      tileMode: TileMode.mirror,
                      colors: <Color>[Colors.grey.shade300, Colors.white],
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: NumberPicker.integer(
                    initialValue: _ptsFor,
                    minValue: 0,
                    maxValue: 200,
                    onChanged: (val) => setState(() => _ptsFor = val),
                  ),
                ),
              ],
            ),
            Expanded(child: Text('')),
            Column(
              children: [
                Text(Messages.of(context).againstPoints,
                    style: Theme.of(context).textTheme.subtitle1),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).dividerColor, width: 1.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerLeft,
                      tileMode: TileMode.mirror,
                      colors: <Color>[Colors.grey.shade300, Colors.white],
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: NumberPicker.integer(
                    initialValue: _ptsAgainst,
                    minValue: 0,
                    maxValue: 200,
                    onChanged: (val) => setState(() => _ptsAgainst = val),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: _updateScore,
                  child: Text(Messages.of(context).finalScoreButton),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    print(_details.inProgress);
    return _finalScoreBits();
  }
}
