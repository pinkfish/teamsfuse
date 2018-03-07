import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

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
      Rect centerSlice,
      bool matchTextDirection: false,
      bool gaplessPlayback: false})
      : super(
            image: getImageProvider(teamUid),
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
            gaplessPlayback: gaplessPlayback);

  static ImageProvider getImageProvider(String teamUid) {
    ImageProvider logo;
    if (UserDatabaseData.instance.teams.containsKey(teamUid)) {
      Team team = UserDatabaseData.instance.teams[teamUid];
      if (team.photoUrl != null) {
        logo = new NetworkImage(team.photoUrl);
      } else {
        logo =
            new AssetImage('assets/sports/' + team.sport.toString() + '.png');
      }
    }
    if (logo == null) {
      logo = new AssetImage('assets/images/defaultavatar.png');
    }
    return logo;
  }
}
