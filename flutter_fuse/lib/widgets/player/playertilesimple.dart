import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/localutilities.dart';
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
class PlayerTileSimple extends StatelessWidget {
  /// PlayerUid to display
  final String playerUid;

  /// Game to display for.
  final String gameUid;

  /// The season to look for jersey numbers in.
  final Season season;

  /// What to do when the player is tapped.
  final PlayerCallbackFunc onTap;

  /// The color of the bar.
  final Color color;

  /// The color of the content.
  final Color contentColor;

  /// The shape for the card.
  final ShapeBorder shape;

  /// Show the chips for the player.
  final bool showChips;

  /// The scale to show the item as.
  final double scale;

  /// Create the player tile for the basketball setup.
  PlayerTileSimple(
      {@required this.playerUid,
      @required this.season,
      @required this.gameUid,
      this.onTap,
      this.color,
      this.contentColor,
      this.shape,
      this.showChips = false,
      this.scale = 1.0})
      : assert((playerUid != null && gameUid != null && season != null));

  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: gameUid,
      builder: (context, singleGameBloc) => BlocBuilder(
          bloc: singleGameBloc,
          builder: (context, gameState) {
            var jerseyNumber =
                season?.playersData[playerUid]?.jerseyNumber ?? 'U';
            if (gameState is SingleGameLoaded) {
              var player = gameState.game.players[playerUid];
              if (player != null && player.jerseyNumber.isNotEmpty) {
                jerseyNumber = player.jerseyNumber;
              }
            }
            return _buildPlayer(context, jerseyNumber);
          }),
    );
  }

  Widget _buildPlayer(BuildContext context, String jerseyNumber) {
    return SinglePlayerProvider(
      playerUid: playerUid,
      builder: (context, singlePlayerBloc) => AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: BlocBuilder(
          bloc: singlePlayerBloc,
          builder: (context, singlePlayerState) {
            if (singlePlayerState is SinglePlayerDeleted) {
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
            if (singlePlayerState is SinglePlayerLoaded) {
              return _loadedData(
                  context, singlePlayerState.player, jerseyNumber);
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
          },
        ),
      ),
    );
  }

  Widget _loadedData(
    BuildContext context,
    Player player,
    String jerseyNumber,
  ) {
    if (jerseyNumber.isEmpty) {
      jerseyNumber = 'U';
    }

    return Card(
      color: color,
      shape: shape,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
        return ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: box.maxHeight < 40.0 ? EdgeInsets.all(1.0) : null,
          onTap: onTap != null ? () => onTap(playerUid) : null,
          title: Text(
            player.name,
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                fontSize: min((box.maxHeight - 5) / 2,
                    Theme.of(context).textTheme.subtitle1.fontSize)),
            overflow: TextOverflow.fade,
            textScaleFactor: 1.0,
            maxLines: 2,
          ),
          leading: Container(
            width: min(box.maxHeight / 2, 40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: LocalUtilities.darken(
                      contentColor ?? Theme.of(context).primaryColor, 40)),
            ),
            child: SizedBox(
              width: min(box.maxHeight / 2, 40),
              height: min(box.maxHeight / 2, 40),
              child: Center(
                child: Text(
                  jerseyNumber,
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: contentColor ?? Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: min(40.0, box.maxHeight - 6) / 2,
                      ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
