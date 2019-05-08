import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'cachednetworkimage.dart';

///
/// Image of the specific player.  Will make an oval clip rect of the specific
/// radius and fill the image to fit that circle.
///
class PlayerImage extends StatelessWidget {
  final double radius;
  final Color backgroundColor;
  final Key key;
  final String playerUid;

  PlayerImage(
      {@required this.playerUid,
      this.key,
      this.backgroundColor,
      this.radius = 20.0});

  static Future<String> getImageUrl(
      String playerUid, BuildContext context) async {
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
    print('Loading for player $playerUid');
    if (playerBloc.currentState.players.containsKey(playerUid)) {
      Player player = playerBloc.currentState.players[playerUid];

      if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
        print('Cached ${player.photoUrl}');
        return new Future<String>(() => player.photoUrl);
      } else {
        return null;
      }
    } else {
      playerBloc.dispatch(PlayerLoadPlayer(playerUid: playerUid));
      await for (PlayerState state in playerBloc.state) {
        Player player = state.getPlayer(playerUid);
        if (player != null) {
          if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
            return player.photoUrl;
          } else {
            return null;
          }
        }
      }
    }
  }

  Widget build(BuildContext context) {
    return ClipOval(
      key: key,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: FittedBox(
          fit: BoxFit.cover,
          child: BlocBuilder(
            bloc: BlocProvider.of<PlayerBloc>(context),
            builder: (BuildContext context, PlayerState playerState) {
              return CachedNetworkImage(
                placeholder: new Image(
                    image:
                        const AssetImage("assets/images/defaultavatar2.png")),
                errorWidget: new Image(
                    image: const AssetImage("assets/images/defaultavatar.png")),
                imageFuture: getImageUrl(playerUid, context),
              );
            },
          ),
        ),
      ),
    );
  }
}
