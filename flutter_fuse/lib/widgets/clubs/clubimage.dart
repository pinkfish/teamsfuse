import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../blocs/singleclubprovider.dart';

///
/// Show the image for the club.
///
class ClubImage extends StatelessWidget {
  /// Constructor.
  ClubImage(
      {@required this.clubUid,
      Key key,
      this.width,
      this.height,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.matchTextDirection = false})
      : super(key: key);

  /// The club to lookup.
  final String clubUid;

  /// The width of the image.
  final double width;

  /// The height of the image.
  final double height;

  /// The fit to use for the image.
  final BoxFit fit;

  /// The alignment to use for the image.
  final AlignmentGeometry alignment;

  /// How we repeat the image.
  final ImageRepeat repeat;

  /// Natching the text direction.
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          if (state is SingleClubDeleted) {
            return CachedNetworkImage(
                key: key,
                width: width,
                height: height,
                placeholder: (context, url) => Image.asset(
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
              placeholder: (context, url) => Image.asset(
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