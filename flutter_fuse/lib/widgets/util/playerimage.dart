import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Image of the specific player.  Will make an oval clip rect of the specific
/// radius and fill the image to fit that circle.
///
class PlayerImage extends StatelessWidget {
  PlayerImage(
      {@required this.playerUid,
      Key key,
      this.backgroundColor,
      this.radius = 20.0})
      : super(key: key);

  final double radius;
  final Color backgroundColor;
  final String playerUid;

  static Future<String> getImageUrl(
      String playerUid, BuildContext context) async {
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
    print('Loading for player $playerUid');
    if (playerBloc.state.players.containsKey(playerUid)) {
      Player player = playerBloc.state.players[playerUid];

      if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
        print('Cached ${player.photoUrl}');
        return Future<String>(() => player.photoUrl);
      } else {
        return null;
      }
    } else {
      playerBloc.add(PlayerLoadPlayer(playerUid: playerUid));
      await for (PlayerState state in playerBloc) {
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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      key: key,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: FittedBox(
          fit: BoxFit.cover,
          child: FutureBuilder(
              future: getImageUrl(playerUid, context),
              builder: (BuildContext context, AsyncSnapshot<String> snap) {
                return CachedNetworkImage(
                  useOldImageOnUrlChange: true,
                  imageUrl: snap.data ?? "",
                  placeholder: (BuildContext context, String url) =>
                      Image.asset("assets/images/defaultavatar2.png"),
                  errorWidget: (BuildContext context, String url, e) => Image(
                      image:
                          const AssetImage("assets/images/defaultavatar2.png")),
                );
              }),
        ),
      ),
    );
  }
}
