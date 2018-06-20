import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';

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
            child: new FadeInImage(
              placeholder: const AssetImage("assets/images/defaultavatar2.png"),
              image: getImageProvider(playerUid),
            ),
          ),
        );

  static ImageProvider getImageProvider(String playerUid) {
    ImageProvider logo;
    if (UserDatabaseData.instance.players.containsKey(playerUid)) {
      Player player = UserDatabaseData.instance.players[playerUid];
      if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
        logo = new NetworkImage(player.photoUrl);
      } else {
        logo = const AssetImage("assets/images/defaultavatar2.png");
      }
    } else {
      logo = new CachedNetworkImageProvider(
          urlFuture: UserDatabaseData.instance
              .getPlayer(playerUid)
              .then((Player player) {
        if (player.photoUrl != null && player.photoUrl.isNotEmpty) {
          return player.photoUrl;
        }
        return null;
      }));
    }
    if (logo == null) {
      logo = const AssetImage("assets/images/defaultavatar2.png");
    }
    return logo;
  }
}
