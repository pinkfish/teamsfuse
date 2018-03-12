import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
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
      return new CachedNetworkImageProvider(urlNow: UserDatabaseData.instance.teams[teamUid].photoUrl);
    }
    return const AssetImage("assets/images/defaultavatar.png");
  }

  static Widget getPlaceholderImage(String teamUid, Color color, BlendMode colorBlendMode) {
     Widget placeholder;

    if (UserDatabaseData.instance.teams.containsKey(teamUid)) {
      Team team = UserDatabaseData.instance.teams[teamUid];
      placeholder =
        new Image(image: new AssetImage('assets/sports/' + team.sport.toString() + '.png'), color: color, colorBlendMode: colorBlendMode);
      } else {
      placeholder =  new Image(image: const AssetImage('assets/images/defaultavatar.png'), color: color, colorBlendMode: colorBlendMode);
    }

    return placeholder;
  }
}
