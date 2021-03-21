import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../blocs/singlegameprovider.dart';
import '../blocs/singleplayerprovider.dart';
import '../blocs/singleseasonprovider.dart';

typedef PlayerCallbackFunc = void Function(String playerUid);
typedef PlayerExtraFunc = Widget Function(String playerUid);

///
/// Shows the details on the player by giving the name and jersey number.
///
class PlayerTileBasketball extends StatelessWidget {
  /// Playeruid to display
  final String playerUid;

  /// Season to display for.
  final String seasonUid;

  /// The game uid to use.
  final String gameUid;

  /// What to do whern the player is tapped.
  final PlayerCallbackFunc onTap;

  /// Edit bbutton, if we should display it.
  final bool editButton;

  /// The color of the bar.
  final Color color;

  /// The color of the content.
  final Color contentColor;

  /// The shape for the card.
  final ShapeBorder shape;

  /// Display a more compact version.
  final bool compactDisplay;

  /// Show the chips for the player.
  final bool showChips;

  /// The function to make to put extra stuff in.
  final PlayerExtraFunc extra;

  /// The scale to show the item as.
  final double scale;

  /// Create the player tile for the basketball setup.
  PlayerTileBasketball(
      {@required this.playerUid,
      this.gameUid,
      this.seasonUid,
      this.onTap,
      this.editButton = true,
      this.color,
      this.contentColor,
      this.shape,
      this.extra,
      this.showChips = false,
      this.compactDisplay = false,
      this.scale = 1.0})
      : assert((playerUid != null && (gameUid != null || seasonUid != null)));

  @override
  Widget build(BuildContext context) {
    if (gameUid != null) {
      return SingleGameProvider(
        gameUid: gameUid,
        builder: (context, singleGameBloc) => BlocBuilder(
            bloc: singleGameBloc,
            builder: (context, gameState) {
              var jerseyNumber = 'U';
              GamePlayerSummary summary;
              if (gameState is SingleGameLoaded) {
                summary = gameState.game.getPlayerSummary(playerUid);
                jerseyNumber = summary?.jerseyNumber ?? 'U';
              }
              return _buildPlayer(context, jerseyNumber, null, summary);
            }),
      );
    } else {
      return SingleSeasonProvider(
        seasonUid: seasonUid,
        builder: (context, singleSeasonBloc) => BlocBuilder(
            bloc: singleSeasonBloc,
            builder: (context, seasonState) {
              var jerseyNumber = 'U';
              SeasonPlayerSummary summary;
              if (seasonState is SingleSeasonLoaded) {
                var player = seasonState.season.playersData[playerUid];
                jerseyNumber = player?.jerseyNumber ?? 'U';
                summary = seasonState.season.playersData[playerUid].summary;
              }
              return _buildPlayer(context, jerseyNumber, summary, null);
            }),
      );
    }
  }

  Widget _chips(BuildContext context, Player player) {
    if (!showChips) {
      return SizedBox(
        height: 0,
      );
    }
    var chips = <Widget>[];

    switch (player.playerType) {
      case PlayerType.player:
        break;
      case PlayerType.guest:
        chips.add(
          Chip(
            label: Text(Messages.of(context).guest),
          ),
        );
        break;
      case PlayerType.seasonGuest:
        chips.add(
          Chip(
            label: Text(Messages.of(context).seasonGuest),
          ),
        );
        break;
      case PlayerType.opponent:
        chips.add(
          Chip(
            label: Text(Messages.of(context).opponent),
          ),
        );
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: chips,
    );
  }

  Widget _buildPlayer(BuildContext context, String jerseyNumber,
      SeasonPlayerSummary summary, GamePlayerSummary gameSummary) {
    return SinglePlayerProvider(
      playerUid: playerUid,
      builder: (context, singlePlayerBloc) => AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: BlocBuilder(
          bloc: singlePlayerBloc,
          builder: (context, singlePlayerState) {
            if (singlePlayerState is SinglePlayerDeleted) {
              if (compactDisplay) {
                return Text(Messages.of(context).unknown);
              }
              return Card(
                color: color,
                shape: shape,
                child: ListTile(
                  title: Text(Messages.of(context).unknown),
                  leading: Stack(
                    children: <Widget>[
                      Icon(MdiIcons.tshirtCrewOutline),
                      Text(''),
                    ],
                  ),
                ),
              );
            }
            if (singlePlayerState is SinglePlayerUninitialized) {
              if (compactDisplay) {
                return Text(Messages.of(context).loading);
              }
              return Card(
                color: color,
                shape: shape,
                child: ListTile(
                  title: Text(Messages.of(context).loading,
                      style: Theme.of(context).textTheme.caption),
                  subtitle: summary != null
                      ? Text(
                          Messages.of(context).seasonSummary(summary),
                        )
                      : null,
                  leading: Stack(
                    children: <Widget>[
                      Icon(MdiIcons.tshirtCrewOutline),
                      Text(''),
                    ],
                  ),
                ),
              );
            }
            if (singlePlayerState is SinglePlayerLoaded) {
              return _loadedData(
                  context, singlePlayerState.player, jerseyNumber, summary);
            }
            return Card(
              color: color,
              shape: shape,
              child: ListTile(
                title: Text(Messages.of(context).unknown),
                subtitle: summary != null
                    ? Text(
                        Messages.of(context).seasonSummary(summary),
                      )
                    : SizedBox(height: 0),
                leading: Stack(
                  children: <Widget>[
                    Icon(MdiIcons.tshirtCrewOutline),
                    Text(''),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loadedData(
      BuildContext context,
      Player loadedPlayer,
      String jerseyNumber,
      SeasonPlayerSummary summary,
      GamePlayerSummary gameSummary) {
    if (compactDisplay) {
      return GestureDetector(
        onTap: () => onTap != null ? onTap(loadedPlayer.uid) : null,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: shape,
          ),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(height: 40.0, width: 40.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Center(
                    child: Text(
                      jerseyNumber,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                    ),
                  ),
                ),
              ),
              (extra != null ? extra(loadedPlayer.uid) : SizedBox(width: 0)),
            ],
          ),
        ),
      );
    }

    return Card(
      color: color,
      shape: shape,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
        return ListTile(
          visualDensity: box.maxHeight < 40.0
              ? VisualDensity.compact
              : VisualDensity.standard,
          contentPadding: box.maxHeight < 40.0 ? EdgeInsets.all(1.0) : null,
          onTap: onTap != null ? () => onTap(loadedPlayer.uid) : null,
          title: Text(
            loadedPlayer.name,
            style: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: min(box.maxHeight - 5,
                    Theme.of(context).textTheme.headline6.fontSize)),
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1.0,
          ),
          leading: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                height: min(40.0, box.maxHeight - 6),
                width: min(40.0, box.maxHeight - 6)),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: contentColor ?? Theme.of(context).primaryColor),
              ),
              child: Center(
                child: Text(
                  jerseyNumber ?? 'U',
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: contentColor ?? Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: min(20.0, box.maxHeight - 12),
                      ),
                ),
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _chips(context, loadedPlayer),
              summary != null
                  ? Text(
                      Messages.of(context).seasonSummary(summary),
                    )
                  : gameSummary != null
                      ? Text(
                          Messages.of(context).gameSummary(gameSummary),
                        )
                      : SizedBox(height: 0),
            ],
          ),
          trailing: editButton
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.pushNamed(
                      context, '/Player/Edit/' + loadedPlayer.uid),
                )
              : null,
        );
      }),
    );
  }
}
