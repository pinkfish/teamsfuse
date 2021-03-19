import 'package:flutter/cupertino.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerlist.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Create just the single line for the playerr data in the season.
///
class SeasonPlayerDetails extends StatelessWidget {
  /// The uid for th4e player
  final String uid;

  /// The season the player is inside.
  final Season season;

  /// constraints for the box.
  final BoxConstraints constraints;

  /// Orientation of th4e screen.
  final Orientation orientation;

  /// What to call when the player is tapped on.
  final PlayerTapFunction onTap;

  SeasonPlayerDetails({
    @required this.uid,
    @required this.season,
    this.constraints,
    this.orientation = Orientation.portrait,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (constraints == null) {
      return LayoutBuilder(
          builder: (context, constraints) =>
              _innerBuilder(context, constraints),

      );
    }
    return _innerBuilder(context, constraints);
  }

  Widget _innerBuilder(BuildContext context, BoxConstraints boxConstraints) {
    var width = boxConstraints.maxWidth / 8;
    var scale = orientation == Orientation.portrait ? 1.0 : 1.5;
    var seasonPlayer = season.playersData[uid];
    var s = seasonPlayer.summary.basketballSummary;
    return GestureDetector(
      onTap: onTap != null
          ? () => onTap(seasonPlayer)
          : () => Navigator.pushNamed(
              context, '/Game/Player/' + season.uid + '/' + uid),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: width * 2,
            child: PlayerName(
              playerUid: uid,
              textScaleFactor: scale,
              fallback: seasonPlayer.jerseyNumber,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.one.made + s.two.made * 2 + s.three.made * 3).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              ((s.one.attempts + s.two.attempts * 2 + s.three.attempts * 3) == 0
                  ? '0%'
                  : ((s.one.made + s.two.made * 2 + s.three.made * 3) /
                              (s.one.attempts +
                                  s.two.attempts * 2 +
                                  s.three.attempts * 3) *
                              100)
                          .toStringAsFixed(0) +
                      '%'),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.fouls).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.turnovers).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.steals).toString(),
              textScaleFactor: scale,
            ),
          ),
          SizedBox(
            width: width,
            child: Text(
              (s.blocks).toString(),
              textScaleFactor: scale,
            ),
          ),
        ],
      ),
    );
  }
}
