import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class PlayerImage extends CircleAvatar {
  PlayerImage(
    String playerUid, {
    Key key,
    double radius = 20.0,
    Color backgroundColor,
  }) : super(
          backgroundColor: backgroundColor,
          radius: radius,
          backgroundImage: getImageProvider(playerUid),
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
      // Lookup the player image, show the defaultavatar and then
      // transform to it.
    }
    if (logo == null) {
      logo = const AssetImage("assets/images/defaultavatar2.png");
    }
    return logo;
  }
}
