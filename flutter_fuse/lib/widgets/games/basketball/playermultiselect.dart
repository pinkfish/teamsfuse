import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/localutilities.dart';
import '../../player/playertilebasketball.dart';

/// Callback for when a player is selected.
typedef PlayerSelectFunction = void Function(String uid, bool selected);

/// Check to see if this player is selected.
typedef PlayerIsSelected = bool Function(String uid);

///
/// Shows the players as a nice grid to be able to select from to setup who
/// is currently playing.
///
class PlayerMultiselect extends StatelessWidget {
  /// Game to get the players for.
  final Game game;

  /// The season to get the players for.
  final Season season;

  /// If the player is selected check
  final PlayerIsSelected isSelected;

  /// Select the specific player.
  final PlayerSelectFunction selectPlayer;

  /// Orientation to display the users,
  final Orientation orientation;

  /// Any specific additional players to pass in.
  final Map<String, Player> additionalPlayers;

  /// The full player details.
  final BuiltMap<String, Player> fullPlayerDetails;

  List<Widget> _populateList(BuildContext context, Orientation o) {
    var players = game.players.keys.toSet();
    var seasonPlayers =
        season != null ? season.playersData.keys.toList() : <String>[];
    seasonPlayers
        .removeWhere((element) => (game.ignoreFromSeason.contains(element)));
    players.addAll(game.opponents.keys);
    players.addAll(seasonPlayers);
    if (additionalPlayers != null) {
      players.addAll(additionalPlayers.keys);
    }
    var ordered = players.toList();
    ordered.sort((String a, String b) {
      var aSummary = game.players[a] ?? game.opponents[a];
      var bSummary = game.players[b] ?? game.opponents[b];
      var aFull = fullPlayerDetails != null ? fullPlayerDetails[a] : null;
      var bFull = fullPlayerDetails != null ? fullPlayerDetails[b] : null;
      if (aSummary == null || bSummary == null) {
        return 0;
      }
      if (aSummary.currentlyPlaying) {
        if (!bSummary.currentlyPlaying) {
          return -1;
        }
      } else if (bSummary.currentlyPlaying) {
        return 1;
      }
      // Sort by number or name.
      if (bSummary.jerseyNumber.isEmpty && aSummary.jerseyNumber.isEmpty) {
        // Order by name.
        if (aFull != null && bFull != null) {
          return aFull.name.compareTo(bFull.name);
        }
      }
      return bSummary.jerseyNumber.compareTo(aSummary.jerseyNumber);
    });
    Color mainColor;
    Color mainColorSelected;
    Color selectedBorder;
    Color unSelectedBorder;
    if (LocalUtilities.isDark(context)) {
      mainColor = Theme.of(context).primaryColor;
      mainColorSelected = Theme.of(context).primaryColor;
      selectedBorder = Theme.of(context).indicatorColor;
      unSelectedBorder = Theme.of(context).primaryColor;
    } else {
      mainColor = LocalUtilities.brighten(Theme.of(context).primaryColor, 96);
      mainColorSelected =
          LocalUtilities.brighten(Theme.of(context).primaryColor, 90);
      selectedBorder = Theme.of(context).indicatorColor;
      unSelectedBorder =
          LocalUtilities.brighten(Theme.of(context).primaryColor, 60);
    }
    return ordered
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTileBasketball(
              playerUid: playerUid,
              gameUid: game.uid,
              showSummary: false,
              color: isSelected(playerUid) ? mainColorSelected : mainColor,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color:
                      isSelected(playerUid) ? selectedBorder : unSelectedBorder,
                  width: 3.0,
                ),
              ),
              onTap: (String playerUid) =>
                  selectPlayer(playerUid, isSelected(playerUid)),
            ),
          ),
        )
        .toList();
  }

  /// Create the player multiselect widget.
  PlayerMultiselect(
      {@required this.game,
      @required this.season,
      @required this.isSelected,
      @required this.selectPlayer,
      this.additionalPlayers,
      this.fullPlayerDetails,
      this.orientation = Orientation.portrait});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, layout) {
      var cols = layout.maxWidth ~/ 200;
      if (cols < 2) {
        cols = 2;
      }
      var aspectRatio = (layout.maxWidth / cols) / 80.0;
      return GridView.count(
        childAspectRatio: aspectRatio,
        crossAxisCount: cols,
        shrinkWrap: true,
        children: _populateList(context, orientation),
      );
    });
  }
}
