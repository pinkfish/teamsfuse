import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../../../services/localutilities.dart';
import '../../../services/messages.dart';
import '../../util/loading.dart';
import 'gameduration.dart';

///
/// Shows the summary of the game in periods.
///
class BasketballGameSummary extends StatelessWidget {
  /// The state to use to show the summary.
  final SingleGameState state;

  /// Create a nice happy summary.
  BasketballGameSummary(this.state);

  String _madeSummary(MadeAttempt attempt) {
    return attempt.made > 0
        ? "${attempt.made}/${attempt.attempts}  " +
            ((attempt.made / attempt.attempts) * 100.0).toStringAsFixed(0) +
            "%"
        : "0/0 (0%)";
  }

  @override
  Widget build(BuildContext context) {
    if (state is SingleGameUninitialized) {
      return LoadingWidget();
    }
    print(state.game.playerSummary);
    TextStyle headerStyle = Theme.of(context).textTheme.subtitle1.copyWith(
        fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.25,
        color: LocalUtilities.darken(Theme.of(context).indicatorColor, 20),
        fontWeight: FontWeight.bold);
    TextStyle dataStyle = Theme.of(context).textTheme.subtitle1.copyWith(
          fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.35,
        );
    TextStyle opponentDataStyle =
        Theme.of(context).textTheme.subtitle1.copyWith(
              fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
            );
    TextStyle pointsStyle = Theme.of(context).textTheme.subtitle1.copyWith(
        fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 4.0);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) =>
          SingleChildScrollView(
        child: Container(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("1pt", style: headerStyle),
                    Text("2pt", style: headerStyle),
                    Text("3pt", style: headerStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_madeSummary(state.game.playerSummary.fullData.one),
                        style: dataStyle),
                    Text(_madeSummary(state.game.playerSummary.fullData.two),
                        style: dataStyle),
                    Text(_madeSummary(state.game.playerSummary.fullData.three),
                        style: dataStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_madeSummary(state.game.opponentSummary.fullData.one),
                        style: opponentDataStyle),
                    Text(_madeSummary(state.game.opponentSummary.fullData.two),
                        style: opponentDataStyle),
                    Text(
                        _madeSummary(state.game.opponentSummary.fullData.three),
                        style: opponentDataStyle),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Foul", style: headerStyle),
                    Text("Steals", style: headerStyle),
                    Text("Turnover", style: headerStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.game.playerSummary.fullData.fouls.toString(),
                        style: dataStyle),
                    Text(state.game.playerSummary.fullData.steals.toString(),
                        style: dataStyle),
                    Text(state.game.playerSummary.fullData.turnovers.toString(),
                        style: dataStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.game.opponentSummary.fullData.fouls.toString(),
                        style: opponentDataStyle),
                    Text(state.game.opponentSummary.fullData.steals.toString(),
                        style: opponentDataStyle),
                    Text(
                        state.game.opponentSummary.fullData.turnovers
                            .toString(),
                        style: opponentDataStyle),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Off Rb", style: headerStyle),
                    Text("Def Db", style: headerStyle),
                    Text("Blocks", style: headerStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        state.game.playerSummary.fullData.offensiveRebounds
                            .toString(),
                        style: dataStyle),
                    Text(
                        state.game.playerSummary.fullData.defensiveRebounds
                            .toString(),
                        style: dataStyle),
                    Text(state.game.playerSummary.fullData.blocks.toString(),
                        style: dataStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        state.game.opponentSummary.fullData.offensiveRebounds
                            .toString(),
                        style: opponentDataStyle),
                    Text(
                        state.game.opponentSummary.fullData.defensiveRebounds
                            .toString(),
                        style: opponentDataStyle),
                    Text(state.game.opponentSummary.fullData.blocks.toString(),
                        style: opponentDataStyle),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
