import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../player/playername.dart';
import '../../../services/messages.dart';

///
/// Shows the list of players in the team.
///
class PlayerList extends StatefulWidget {
  /// The orientation of the list.
  final Orientation orientation;

  /// The season to display the list for.
  final Season season;

  /// the Game to display the list for.
  final Game game;

  /// The additional players to display.
  final Map<String, Player> additionalPlayers;

  /// The extra details for the playet to display.
  final BuiltMap<String, Player> fullPlayerDetails;

  /// Creates the player list with all the useful data.
  PlayerList(
      {this.orientation = Orientation.portrait,
      @required this.game,
      @required this.season,
      this.additionalPlayers,
      this.fullPlayerDetails});

  @override
  State<StatefulWidget> createState() {
    return _PlayerListState();
  }
}

///
/// How to sort the players in the list.
///
enum SortPlayerBy {
  Points,
  Fouls,
  Turnovers,
  Steals,
  Blocks,
  MadePercentage,
  Name,
}

class _PlayerListState extends State<PlayerList> {
  SortPlayerBy _sortBy = SortPlayerBy.Points;

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
        var sortedList = widget.game.players.keys.toList();
        if (widget.season != null) {
          var seasonList = widget.season.playersData.keys.toList();
          // Only track things not in the current list and not ignored.
          seasonList.removeWhere((e) =>
              widget.game.ignoreFromSeason.contains(e) ||
              sortedList.contains(e));
          sortedList.addAll(seasonList);
        }
        if (widget.additionalPlayers != null) {
          sortedList.addAll(widget.additionalPlayers.keys);
        }
        sortedList.sort((String u1, String u2) =>
            _sortFunction(u1, _getData(u1), u2, _getData(u2)));
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: width * 2,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Name),
                      child: Text(
                        '',
                        style:
                            minDataStyle.copyWith(fontWeight: FontWeight.bold),
                        textScaleFactor: scale,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Points),
                      child: Text(
                        Messages.of(context).pointsTitle,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Points
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.MadePercentage),
                      child: Text(
                        Messages.of(context).percentageTitle,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.MadePercentage
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Fouls),
                      child: Text(
                        Messages.of(context).foulsGameSummary,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Fouls
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Turnovers),
                      child: Text(
                        Messages.of(context).turnoversTitle,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Turnovers
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Steals),
                      child: Text(
                        Messages.of(context).stealsTitle,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Steals
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _sortBy = SortPlayerBy.Blocks),
                      child: Text(
                        Messages.of(context).blocksTitle,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: minDataStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _sortBy == SortPlayerBy.Blocks
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        textScaleFactor: scale,
                      ),
                    ),
                  ),
                ],
              ),
              ...sortedList
                  .map((String s) => _playerSummary(
                      s, _getData(s), constraints, widget.orientation))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  PlayerSummaryData _getData(String playerUid) {
    return widget.game.players[playerUid]?.fullData ??
        widget.season?.playersData[playerUid]?.summary ??
        PlayerSummaryData();
  }

  int _sortFunction(
      String u1, PlayerSummaryData s1, String u2, PlayerSummaryData s2) {
    switch (_sortBy) {
      case SortPlayerBy.Points:
        return s2.points - s1.points;
      case SortPlayerBy.Fouls:
        return s2.fouls - s1.fouls;
      case SortPlayerBy.Turnovers:
        return s2.turnovers - s1.turnovers;
      case SortPlayerBy.Steals:
        return s2.steals - s1.steals;
      case SortPlayerBy.Blocks:
        return s2.blocks - s1.blocks;
      case SortPlayerBy.MadePercentage:
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
        return 0;
      case SortPlayerBy.Name:
        if (widget.fullPlayerDetails != null) {
          var n1 = widget.fullPlayerDetails[u1];
          var n2 = widget.fullPlayerDetails[u2];
          if (n1 == null && n2 == null) {
            return 0;
          }
          if (n1 == null) {
            return 1;
          }
          if (n2 == null) {
            return -1;
          }
          return n1.name.compareTo(n2.name);
        }
    }
    return 0;
  }

  Widget _playerSummary(String uid, PlayerSummaryData s,
      BoxConstraints constraints, Orientation orientation) {
    var width = constraints.maxWidth / 8;
    var scale = orientation == Orientation.portrait ? 1.0 : 1.5;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, '/Game/Player/' + widget.game.uid + '/' + uid),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: width * 2,
            child: PlayerName(
              playerUid: uid,
              textScaleFactor: scale,
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
