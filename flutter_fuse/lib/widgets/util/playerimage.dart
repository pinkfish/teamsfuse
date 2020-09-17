import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

///
/// Image of the specific player.  Will make an oval clip rect of the specific
/// radius and fill the image to fit that circle.
///
class PlayerImage extends StatelessWidget {
  /// Constructor.
  PlayerImage(
      {@required this.playerUid,
      Key key,
      this.backgroundColor,
      this.radius = 20.0})
      : assert(playerUid != null),
        super(key: key);

  /// Radius of the circle to put the player image inside.
  final double radius;

  /// Background color of the circle.
  final Color backgroundColor;

  /// The playerUid to lookup.
  final String playerUid;

  static Future<String> _getImageUrl(
      String playerUid, BuildContext context) async {
    var playerBloc = BlocProvider.of<PlayerBloc>(context);
    if (playerBloc.state.players.containsKey(playerUid)) {
      var player = playerBloc.state.players[playerUid];

      if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
        return Future<String>(() => player.photoUrl);
      } else {
        return null;
      }
    } else {
      playerBloc.add(PlayerLoadPlayer(playerUid: playerUid));
      await for (PlayerState state in playerBloc) {
        var player = state.getPlayer(playerUid);
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
              future: _getImageUrl(playerUid, context),
              builder: (context, snap) {
                return CachedNetworkImage(
                  useOldImageOnUrlChange: true,
                  imageUrl: snap.data ?? "",
                  placeholder: (context, url) =>
                      Image.asset("assets/images/defaultavatar2.png"),
                  errorWidget: (context, url, e) => Image(
                      image:
                          const AssetImage("assets/images/defaultavatar2.png")),
                );
              }),
        ),
      ),
    );
  }
}
