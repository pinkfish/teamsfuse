import 'package:flutter/cupertino.dart';
import 'package:flutter_fuse/widgets/teams/stats/playerdetailrow.dart';
import 'package:fusemodel/fusemodel.dart';

import 'seasonplayerlist.dart';
import '../../player/playername.dart';
import '../../util/publicmark.dart';

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

  /// If we should show the name column.
  final bool showName;

  SeasonPlayerDetails({
    @required this.uid,
    @required this.season,
    this.constraints,
    this.orientation = Orientation.portrait,
    this.onTap,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    if (constraints == null) {
      return LayoutBuilder(
        builder: (context, constraints) => _innerBuilder(context, constraints),
      );
    }
    return _innerBuilder(context, constraints);
  }

  Widget _innerBuilder(BuildContext context, BoxConstraints boxConstraints) {
    var seasonPlayer = season.playersData[uid];
    var s = seasonPlayer.summary.basketballSummary;

    return PublicMark(
      isPublic: seasonPlayer.isPublic,
      child: GestureDetector(
        onTap: onTap != null
            ? () => onTap(seasonPlayer)
            : () => Navigator.pushNamed(
                context, '/Game/Player/' + season.uid + '/' + uid),
        child: PlayerDetailRow(
          boxConstraints,
          orientation,
          uid,
          seasonPlayer,
          s,
          showName: showName,
        ),
      ),
    );
  }
}
