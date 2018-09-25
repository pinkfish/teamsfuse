import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';
import 'dart:async';

class ClubImage extends CachedNetworkImage {
  ClubImage(
      {@required String clubUid,
      Key key,
      double width,
      double height,
      Color color,
      BlendMode colorBlendMode,
      BoxFit fit,
      AlignmentGeometry alignment: Alignment.center,
      ImageRepeat repeat: ImageRepeat.noRepeat,
      bool matchTextDirection: false})
      : super(
            imageFuture: getImageURL(clubUid),
            placeholder: new Image.asset("assets/images/defaultavatar.png"),
            key: key,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection);

  static Future<String> getImageURL(String clubUid) async {
    Club club = await UserDatabaseData.instance.getClub(clubUid);
    if (club != null) {
      String photoUrl = club.photoUrl;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return photoUrl;
      }
    }
    return null;
  }
}
