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
  final Game game;

  /// Create a nice happy summary.
  BasketballGameSummary(this.game);

  String _madeSummary(MadeAttempt attempt) {
    return attempt.made > 0
        ? "${attempt.made}/${attempt.attempts}  " +
            ((attempt.made / attempt.attempts) * 100.0).toStringAsFixed(0) +
            "%"
        : "0/0 (0%)";
  }

  @override
  Widget build(BuildContext context) {
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
    //TextStyle pointsStyle = Theme.of(context).textTheme.subtitle1.copyWith(
    //    fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 4.0);

    return Column(
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
            Text(_madeSummary(game.playerSummary.fullData.one),
                style: dataStyle),
            Text(_madeSummary(game.playerSummary.fullData.two),
                style: dataStyle),
            Text(_madeSummary(game.playerSummary.fullData.three),
                style: dataStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_madeSummary(game.opponentSummary.fullData.one),
                style: opponentDataStyle),
            Text(_madeSummary(game.opponentSummary.fullData.two),
                style: opponentDataStyle),
            Text(_madeSummary(game.opponentSummary.fullData.three),
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
            Text(game.playerSummary.fullData.fouls.toString(),
                style: dataStyle),
            Text(game.playerSummary.fullData.steals.toString(),
                style: dataStyle),
            Text(game.playerSummary.fullData.turnovers.toString(),
                style: dataStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(game.opponentSummary.fullData.fouls.toString(),
                style: opponentDataStyle),
            Text(game.opponentSummary.fullData.steals.toString(),
                style: opponentDataStyle),
            Text(game.opponentSummary.fullData.turnovers.toString(),
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
            Text(game.playerSummary.fullData.offensiveRebounds.toString(),
                style: dataStyle),
            Text(game.playerSummary.fullData.defensiveRebounds.toString(),
                style: dataStyle),
            Text(game.playerSummary.fullData.blocks.toString(),
                style: dataStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(game.opponentSummary.fullData.offensiveRebounds.toString(),
                style: opponentDataStyle),
            Text(game.opponentSummary.fullData.defensiveRebounds.toString(),
                style: opponentDataStyle),
            Text(game.opponentSummary.fullData.blocks.toString(),
                style: opponentDataStyle),
          ],
        ),
      ],
    );
  }
}
