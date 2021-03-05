import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleclubcoachprovider.dart';

///
/// Show the image for the coach.
///
class CoachImage extends StatelessWidget {
  /// Constructor.
  CoachImage(
      {@required this.clubUid,
      @required this.coachUid,
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

  /// The uid for the coach.
  final String coachUid;

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
    return SingleClubCoachProvider(
      clubUid: clubUid,
      coachUid: coachUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          Widget img;
          if (state is SingleClubCoachUninitialized ||
              state is SingleClubCoachDeleted ||
              state.coach.photoUrl == null ||
              state.coach.photoUrl.isEmpty) {
            img = Image.asset('assets/images/defaultavatar.png',
                key: key,
                width: width,
                height: height,
                alignment: alignment,
                repeat: repeat,
                matchTextDirection: matchTextDirection);
          } else {
            img = CachedNetworkImage(
              key: key,
              width: width,
              height: height,
              placeholder: (context, url) => Image.asset(
                'assets/images/defaultavatar.png',
                width: width,
                height: height,
                fit: fit,
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/defaultavatar.png',
                width: width,
                height: height,
                fit: fit,
              ),
              alignment: alignment,
              repeat: repeat,
              matchTextDirection: matchTextDirection,
              imageUrl: state.coach.photoUrl,
            );
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: ClipOval(child: img),
          );
        },
      ),
    );
  }
}
