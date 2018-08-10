import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';

///
/// Image of the specific player.  Will make an oval clip rect of the specific
/// radius and fill the image to fit that circle.
///
class PlayerImage extends ClipOval {
  PlayerImage({
    @required String playerUid,
    Key key,
    double radius = 20.0,
    Color backgroundColor,
  }) : super(
          child: new SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: new FittedBox(
              fit: BoxFit.cover,
              child: new CachedNetworkImage(
                placeholder: new Image(
                    image:
                        const AssetImage("assets/images/defaultavatar2.png")),
                errorWidget: new Image(
                    image: const AssetImage("assets/images/defaultavatar.png")),
                imageFuture: getImageUrl(playerUid),
              ),
            ),
          ),
        );

  static Future<String> getImageUrl(String playerUid) async {
    print('Loading for player $playerUid');
    if (UserDatabaseData.instance.players.containsKey(playerUid)) {
      Player player = UserDatabaseData.instance.players[playerUid];

      if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
        print('Cached ${player.photoUrl}');
        return new Future<String>(() => player.photoUrl);
      } else {
        return null;
      }
    } else {
      return UserDatabaseData.instance
          .getPlayer(playerUid)
          .then((Player player) {
        print('Found player $playerUid $player');
        if (player != null &&
            player.photoUrl != null &&
            player.photoUrl.isNotEmpty) {
          return player.photoUrl;
        }
        return null;
      }).catchError((dynamic e) {
        // error!
        return null;
      });
    }
  }
}
