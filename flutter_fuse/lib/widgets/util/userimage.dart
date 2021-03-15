import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleprofileprovider.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

///
/// Displays the user image.
///
class UserImage extends StatelessWidget {
  /// Constructor.
  UserImage(
    this.userId, {
    Key key,
    this.radius = 20.0,
    this.backgroundColor,
  })  : assert(userId != null),
        super(key: key);

  /// The profile to display the user for.
  final String userId;

  /// The radius of the circle.
  final double radius;

  /// The background color of the circle.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SingleProfileProvider(
      userUid: userId,
      builder: (context, bloc) => CircleAvatar(
        backgroundColor: backgroundColor,
        radius: radius,
        child: BlocBuilder(
          cubit: bloc,
          builder: (context, state) {
            if (state is SingleProfileLoaded && !state.loadedMePlayer) {
              bloc.add(SingleProfileLoadMePlayer());
            }

            return AnimatedCrossFade(
              duration: Duration(seconds: 3),
              crossFadeState:
                  state.loadedMePlayer && state.mePlayer.photoUrl.isNotEmpty
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              firstChild: Text(
                state.profile?.initials() ?? '..',
              ),
              secondChild: state.loadedMePlayer
                  ? CachedNetworkImage(
                      imageUrl: state.mePlayer.photoUrl,
                    )
                  : Text(''),
            );
          },
        ),
      ),
    );
  }
}
