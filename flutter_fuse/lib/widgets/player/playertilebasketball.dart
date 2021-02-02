import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamseasonplayerprovider.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';

typedef void PlayerCallbackFunc(String playerUid);
typedef Widget PlayerExtraFunc(String playerUid);

///
/// Shows the details on the player by giving the name and jersey number.
///
class PlayerTileBasketball extends StatelessWidget {
  final String playerUid;
  final String seasonUid;
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
      {this.playerUid,
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
      : assert((playerUid != null && seasonUid != null));

  @override
  Widget build(BuildContext context) {
    return _innerBuild(context);
  }

  Widget _innerBuild(BuildContext context) {
    return SingleTeamSeasonPlayerProvider(
      seasonUid: seasonUid,
      playerUid: playerUid,
      builder: (context, seasonPlayerBloc) => BlocBuilder(
        cubit: seasonPlayerBloc,
        builder: (context, seasonPlayerState) => BlocProvider(
          create: (BuildContext context) => SinglePlayerBloc(
              playerUid: this.playerUid,
              db: RepositoryProvider.of<DatabaseUpdateModel>(context)),
          child: Builder(
            builder: (BuildContext context) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: BlocBuilder(
                  cubit: BlocProvider.of<SinglePlayerBloc>(context),
                  builder: (BuildContext context, SinglePlayerState state) {
                    if (state is SinglePlayerDeleted) {
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
                              Text(""),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is SinglePlayerUninitialized) {
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
                              Text(""),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is SinglePlayerLoaded) {
                      return _loadedData(context,
                          seasonPlayerState.seasonPlayer, state.player);
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
                            Text(""),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _loadedData(
      BuildContext context, SeasonPlayer player, Player loadedPlayer) {
    if (compactDisplay) {
      return GestureDetector(
        onTap: () => onTap != null ? onTap(player.playerUid) : null,
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
                  child: Center(
                    child: Text(
                      player.jerseyNumber,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              Text(
                loadedPlayer.name,
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.ellipsis,
              ),
              (this.extra != null
                  ? extra(player.playerUid)
                  : SizedBox(width: 0)),
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
          onTap: onTap != null ? () => onTap(player.playerUid) : null,
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
              child: Center(
                child: Text(
                  player.jerseyNumber ?? "U",
                  style: Theme.of(context).textTheme.caption.copyWith(
                        color: contentColor ?? Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: min(20.0, box.maxHeight - 12),
                      ),
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: contentColor ?? Theme.of(context).primaryColor),
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
                      context, "/Player/Edit/" + player.playerUid),
                )
              : null,
        );
      }),
    );
  }
}
