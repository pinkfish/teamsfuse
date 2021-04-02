import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:fusemodel/fusemodel.dart';

class PlayerDetailRow extends StatelessWidget {
  /// If we should show the name column.
  final bool showName;

  /// constraints for the box.
  final BoxConstraints constraints;

  /// Orientation of th4e screen.
  final Orientation orientation;

  /// The uid of the player
  final String playerUid;

  /// The season player details to show.
  final SeasonPlayer seasonPlayer;

  /// The summary data to display.
  final PlayerSummaryData summaryData;

  /// What to show for the name.
  final String nameOverride;

  /// Constructor for the class.
  PlayerDetailRow(this.constraints, this.orientation, this.playerUid,
      this.seasonPlayer, this.summaryData,
      {this.showName = true, this.nameOverride});

  @override
  Widget build(BuildContext context) {
    var width = constraints.maxWidth / (showName ? 8 : 6);
    var scale = orientation == Orientation.portrait ? 1.0 : 1.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ...showName
            ? [
                SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: width * 2 - 5,
                  child: nameOverride == null
                      ? PlayerName(
                          playerUid: playerUid,
                          textScaleFactor: scale,
                          fallback: seasonPlayer.jerseyNumber,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                        )
                      : Text(
                          nameOverride,
                          overflow: TextOverflow.fade,
                          textScaleFactor: scale,
                          maxLines: 1,
                        ),
                ),
              ]
            : [],
        SizedBox(
          width: width,
          child: Text(
            (summaryData.one.made +
                    summaryData.two.made * 2 +
                    summaryData.three.made * 3)
                .toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            ((summaryData.one.attempts +
                        summaryData.two.attempts * 2 +
                        summaryData.three.attempts * 3) ==
                    0
                ? '0%'
                : ((summaryData.one.made +
                                summaryData.two.made * 2 +
                                summaryData.three.made * 3) /
                            (summaryData.one.attempts +
                                summaryData.two.attempts * 2 +
                                summaryData.three.attempts * 3) *
                            100)
                        .toStringAsFixed(0) +
                    '%'),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (summaryData.fouls).toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (summaryData.turnovers).toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (summaryData.steals).toString(),
            textScaleFactor: scale,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            (summaryData.blocks).toString(),
            textScaleFactor: scale,
          ),
        ),
      ],
    );
  }
}
