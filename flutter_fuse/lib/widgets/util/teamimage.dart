import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';

class TeamImage extends Image {
  TeamImage(String teamUid,
      {Key key,
      double width,
      double height,
      Color color,
      BlendMode colorBlendMode,
      BoxFit fit,
      AlignmentGeometry alignment: Alignment.center,
      ImageRepeat repeat: ImageRepeat.noRepeat,
      bool matchTextDirection: false})
      : super(
            image: getImageURL(teamUid),
      key: key,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
             matchTextDirection: matchTextDirection);

  static ImageProvider getImageURL(String teamUid) {
    if (UserDatabaseData.instance.teams.containsKey(teamUid)) {
      String photoUrl = UserDatabaseData.instance.teams[teamUid].photoUrl;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return new CachedNetworkImageProvider(urlNow: photoUrl);
      }
      switch (UserDatabaseData.instance.teams[teamUid].sport) {
        case Sport.Basketball:
          return const AssetImage("assets/sports/Sport.Basketball.png");
        case Sport.Soccer:
          return const AssetImage("assets/sports/Sport.Soccer.png");
        default:
          break;
      }
    }
    return const AssetImage("assets/images/defaultavatar.png");
  }
}
