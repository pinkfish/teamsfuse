import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/localutilities.dart';
import '../../player/playertilebasketball.dart';

typedef SelectPlayerCallback = void Function(
    BuildContext context, String playerUid);
typedef FilterPlayerCallback = bool Function(String playerUid);
typedef SortPlayerCallback = int Function(Game game, String p1, String p2);

///
/// List showing all the players on the team to be selectable in a dialog.
///
class GamePlayerList extends StatelessWidget {
  final Game game;
  final SelectPlayerCallback onSelectPlayer;
  final FilterPlayerCallback filterPlayer;
  final Orientation orientation;
  final String selectedPlayer;
  final bool compactDisplay;
  final PlayerExtraFunc extra;
  final SortPlayerCallback sort;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    var players = game.players.keys.toList();
    players.addAll(game.opponents.keys);
    players.sort((String p1, String p2) => sort(game, p1, p2));
    return players
        .where((String playerUid) => filterPlayer != null && playerUid != null
            ? filterPlayer(playerUid)
            : false)
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTileBasketball(
              extra: extra,
              gameUid: game.uid,
              compactDisplay: compactDisplay,
              playerUid: playerUid,
              editButton: false,
              color: selectedPlayer == playerUid
                  ? Theme.of(context).splashColor
                  : LocalUtilities.isDark(context)
                      ? Theme.of(context).primaryColor
                      : LocalUtilities.brighten(
                          Theme.of(context).primaryColor, 80),
              onTap: onSelectPlayer != null
                  ? (String playerUid) => onSelectPlayer(context, playerUid)
                  : null,
            ),
          ),
        )
        .toList();
  }

  GamePlayerList(
      {@required this.game,
      @required this.onSelectPlayer,
      @required this.orientation,
      this.filterPlayer,
      this.selectedPlayer,
      this.extra,
      this.sort = _sortFunc,
      this.compactDisplay = false});

  static int _sortFunc(Game game, String a, String b) {
    var asum = game.players[a] ?? game.opponents[a];
    var bsum = game.players[b] ?? game.opponents[b];
    if (asum.currentlyPlaying) {
      return -1;
    }
    if (bsum.currentlyPlaying) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: _populateList(context, orientation),
    );
  }
}
