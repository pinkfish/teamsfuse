import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final String playerUid;
  final String seasonUid;
  final String gameUid;
  final PlayerCallbackFunc onTap;
  final bool editButton;
  final Color color;
  final Color contentColor;
  final ShapeBorder shape;
  final bool compactDisplay;
  final PlayerExtraFunc extra;
  final SeasonPlayerSummary summary;
  final double scale;

  PlayerTileBasketball(
      {@required this.playerUid,
      this.gameUid,
      this.seasonUid,
      this.onTap,
      this.editButton = true,
      this.color,
      this.contentColor,
      this.summary,
      this.shape,
      this.extra,
      this.compactDisplay = false,
      this.scale = 1.0})
      : assert((playerUid != null && (gameUid != null || seasonUid != null)));

  @override
  Widget build(BuildContext context) {
    if (gameUid != null) {
      return SingleGameProvider(
        gameUid: gameUid,
        builder: (context, singleGameBloc) => BlocBuilder(
            cubit: singleGameBloc,
            builder: (context, gameState) {
              var jerseyNumber = 'U';
              if (gameState is SingleGameLoaded) {
                var player = gameState.game.getPlayerSummary(playerUid);
                jerseyNumber = player?.jerseyNumber ?? 'U';
              }
              return _buildPlayer(context, jerseyNumber);
            }),
      );
    } else {
      return SingleSeasonProvider(
        seasonUid: seasonUid,
        builder: (context, singleSeasonBloc) => BlocBuilder(
            cubit: singleSeasonBloc,
            builder: (context, seasonState) {
              var jerseyNumber = 'U';
              if (seasonState is SingleSeasonLoaded) {
                var player = seasonState.season.playersData[playerUid];
                jerseyNumber = player?.jerseyNumber ?? 'U';
              }
              return _buildPlayer(context, jerseyNumber);
            }),
      );
    }
  }

  Widget _buildPlayer(BuildContext context, String jerseyNumber) {
    return SinglePlayerProvider(
      playerUid: playerUid,
      builder: (context, singlePlayerBloc) => AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: BlocBuilder(
          cubit: singlePlayerBloc,
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
                  context, singlePlayerState.player, jerseyNumber);
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
                    : null,
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
      BuildContext context, Player loadedPlayer, String jerseyNumber) {
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
              Text(
                loadedPlayer.name,
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
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
          subtitle: summary != null
              ? Text(
                  Messages.of(context).seasonSummary(summary),
                )
              : null,
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
