import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerdetail.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerheader.dart';
import 'package:fusemodel/fusemodel.dart';

/// Called when the player is tapped on.
typedef PlayerTapFunction = void Function(SeasonPlayer player);

///
/// Shows the list of players in the season with stats.
///
class SeasonPlayerList extends StatefulWidget {
  final Orientation orientation;
  final Season season;
  final PlayerTapFunction onTap;

  SeasonPlayerList(
      {this.orientation = Orientation.portrait,
      @required this.season,
      this.onTap});

  @override
  State<StatefulWidget> createState() {
    return _PlayerListState();
  }
}

/// The order to sort players in the season list.
enum SortPlayerBy {
  points,
  fouls,
  turnovers,
  steals,
  blocks,
  madePercentage,
}

class _PlayerListState extends State<SeasonPlayerList> {
  SortPlayerBy _sortBy = SortPlayerBy.points;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        var minDataStyle = Theme.of(context).textTheme.subtitle1.copyWith(
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize * 1.25);

        var width = constraints.maxWidth / 8;
        var scale = widget.orientation == Orientation.portrait ? 1.0 : 1.2;
        var sortedList = widget.season.playersData.keys.toList();
        if (widget.season != null) {
          var seasonList = widget.season.playersData.keys.toList();
          // Only track things not in the current list and not ignored.
          seasonList.removeWhere((e) =>
              !widget.season.playersData[e].isPublic || sortedList.contains(e));
          sortedList.addAll(seasonList);
        }
        sortedList.sort((String u1, String u2) =>
            _sortFunction(_getData(u1), _getData(u2)));
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Column(
            children: [
              SeasonPlayerHeader(
                width: width,
                scale: scale,
                sortBy: _sortBy,
                onSort: (s) => setState(() => _sortBy = s),
                style: minDataStyle,
              ),
              ...sortedList
                  .map(
                    (String s) => Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: SeasonPlayerDetails(
                          uid: s,
                          season: widget.season,
                          constraints: constraints,
                          orientation: widget.orientation,
                          onTap: widget.onTap,
                        )),
                  )
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  PlayerSummaryData _getData(String playerUid) {
    return widget.season.playersData[playerUid]?.summary?.basketballSummary ??
        PlayerSummaryData();
  }

  int _sortFunction(PlayerSummaryData s1, PlayerSummaryData s2) {
    switch (_sortBy) {
      case SortPlayerBy.points:
        return s2.points - s1.points;
      case SortPlayerBy.fouls:
        return s2.fouls - s1.fouls;
      case SortPlayerBy.turnovers:
        return s2.turnovers - s1.turnovers;
      case SortPlayerBy.steals:
        return s2.steals - s1.steals;
      case SortPlayerBy.blocks:
        return s2.blocks - s1.blocks;
      case SortPlayerBy.madePercentage:
        if ((s2.one.attempts + s2.two.attempts + s2.three.attempts) > 0) {
          if ((s1.one.attempts + s1.two.attempts + s1.three.attempts) > 0) {
            return ((s2.one.made + s2.two.made + s2.three.made) ~/
                    (s2.one.attempts + s2.two.attempts + s2.three.attempts)) -
                ((s1.one.made + s1.two.made + s1.three.made) ~/
                    (s1.one.attempts + s1.two.attempts + s1.three.attempts));
          }
          return 1;
        } else if ((s1.one.attempts + s1.two.attempts + s1.three.attempts) >
            0) {
          return -1;
        }
    }
    return 0;
  }
}
