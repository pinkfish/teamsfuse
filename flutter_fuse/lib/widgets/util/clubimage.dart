import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'cachednetworkimage.dart';

class ClubImage extends Image {
  ClubImage(Club club,
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
            image: getImageURL(club),
            key: key,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            matchTextDirection: matchTextDirection);

  static ImageProvider getImageURL(Club club) {
    String photoUrl = club.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return new CachedNetworkImageProvider(urlNow: photoUrl);
    }
    return const AssetImage("assets/images/defaultavatar.png");
  }
}
