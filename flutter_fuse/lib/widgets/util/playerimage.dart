import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class PlayerImage extends CircleAvatar {
  PlayerImage(String playerUid,
      {Key key,
      double width,
      double height,
      Color color,
      Color backgroundColor,
      BlendMode colorBlendMode,
      BoxFit fit,
      AlignmentGeometry alignment: Alignment.center,
      ImageRepeat repeat: ImageRepeat.noRepeat,
      Rect centerSlice,
      bool matchTextDirection: false,
      bool gaplessPlayback: false})
      : super(
            backgroundColor: backgroundColor,
            radius: width == null ? 20.0 : (width < height ? width / 2: height / 2),
            child: new Image(
                image: getImageProvider(playerUid),
                key: key,
                width: width,
                height: height,
                color: color,
                colorBlendMode: colorBlendMode,
                fit: fit,
                alignment: alignment,
                repeat: repeat,
                centerSlice: centerSlice,
                matchTextDirection: matchTextDirection,
                gaplessPlayback: gaplessPlayback));

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
