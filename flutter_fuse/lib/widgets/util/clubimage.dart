import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleclubprovider.dart';
import 'cachednetworkimage.dart';

class ClubImage extends StatelessWidget {
  ClubImage(
      {@required this.clubUid,
      Key key,
      this.width,
      this.height,
      this.fit,
      this.alignment: Alignment.center,
      this.repeat: ImageRepeat.noRepeat,
      this.matchTextDirection: false})
      : super(key: key);

  final String clubUid;
  final double width;
  final double height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;

  static Future<String> getImageURL(Club club) async {
    if (club != null) {
      String photoUrl = club.photoUrl;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return photoUrl;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (BuildContext context, SingleClubBloc bloc) => BlocBuilder(
        cubit: bloc,
        builder: (BuildContext context, SingleClubState state) {
          if (state is SingleClubDeleted) {
            return CachedNetworkImage(
                key: key,
                width: width,
                height: height,
                placeholder: new Image.asset(
                  "assets/images/defaultavatar.png",
                  width: width,
                  height: height,
                  fit: fit,
                ),
                alignment: alignment,
                repeat: repeat,
                matchTextDirection: matchTextDirection,
                imageUrl: state.club.photoUrl);
          } else {
            return CachedNetworkImage(
              key: key,
              width: width,
              height: height,
              placeholder: new Image.asset(
                "assets/images/defaultavatar.png",
                width: width,
                height: height,
                fit: fit,
              ),
              alignment: alignment,
              repeat: repeat,
              matchTextDirection: matchTextDirection,
              imageUrl: null,
            );
          }
        },
      ),
    );
  }
}
