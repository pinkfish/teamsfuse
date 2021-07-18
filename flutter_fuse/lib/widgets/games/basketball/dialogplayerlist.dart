import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/player/playertilebasketball.dart';
import 'package:flutter_fuse/widgets/player/playertilesimple.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/localutilities.dart';

typedef SelectPlayerCallback = void Function(
    BuildContext context, String playerUid);
typedef FilterPlayerCallback = bool Function(String playerUid);

///
/// List showing all the players on the team to be selectable in a dialog.
///
class DialogPlayerList extends StatelessWidget {
  final Game game;
  final SelectPlayerCallback onSelectPlayer;
  final FilterPlayerCallback filterPlayer;
  final Orientation orientation;
  final double scale;

  List<Widget> _populateList(
      BuildContext context, Orientation o, SingleSeasonState seasonState) {
    var players = game.players.keys.toList();
    players.addAll(game.opponents.keys);
    players.sort((String a, String b) {
      var aSummary = game.players[a] ?? game.opponents[a];
      var bSummary = game.players[b] ?? game.opponents[b];
      if (aSummary.currentlyPlaying) {
        return -1;
      }
      if (bSummary.currentlyPlaying) {
        return 1;
      }
      return 0;
    });
    var contentColor = (String playerUid) => game.players.containsKey(playerUid)
        ? Theme.of(context).indicatorColor
        : LocalUtilities.isDark(context)
            ? Theme.of(context).primaryColor
            : Colors.lightBlueAccent;
    return players
        .where((String playerUid) =>
            filterPlayer != null ? filterPlayer(playerUid) : true)
        .map(
          (String playerUid) => Padding(
            padding: EdgeInsets.all(2.0),
            child: PlayerTileSimple(
              playerUid: playerUid,
              season: seasonState.season,
              gameUid: game.uid,
              scale: scale,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: contentColor(playerUid),
                  width: 3.0,
                ),
              ),
              contentColor: contentColor(playerUid),
              onTap: (String playerUid) => onSelectPlayer(context, playerUid),
            ),
          ),
        )
        .toList();
  }

  DialogPlayerList(
      {@required this.game,
      @required this.onSelectPlayer,
      @required this.orientation,
      this.filterPlayer,
      this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return SingleSeasonProvider(
      seasonUid: game.seasonUid,
      builder: (context, seasonBloc) => BlocBuilder(
        bloc: seasonBloc,
        builder: (context, seasonState) => ((orientation ==
                Orientation.portrait)
            ? LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) {
                var width = box.maxWidth / 2;
                var minHeight = 60.0;
                var ratio = min(width / minHeight, 3.0);
                return GridView.count(
                  childAspectRatio: ratio,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  primary: false,
                  children: _populateList(context, orientation, seasonState),
                );
              })
            : GridView.count(
                childAspectRatio: 2.5,
                crossAxisCount: 4,
                shrinkWrap: true,
                primary: false,
                children: _populateList(context, orientation, seasonState),
              )),
      ),
    );
  }
}
