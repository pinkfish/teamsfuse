import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleprofileprovider.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Displays the user image.
///
class UserImage extends StatelessWidget {
  /// Constructor.
  UserImage(
    this.profile, {
    Key key,
    this.radius = 20.0,
    this.backgroundColor,
  })  : assert(profile != null),
        super(key: key);

  /// The profile to display the user for.
  final FusedUserProfile profile;

  /// The radius of the circle.
  final double radius;

  /// The background color of the circle.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SingleProfileProvider(
      userUid: profile.uid,
      builder: (context, bloc) => CircleAvatar(
        backgroundColor: backgroundColor,
        radius: radius,
        child: BlocProvider(
          create: (context) => bloc,
          child: BlocConsumer(
            cubit: bloc,
            builder: (context, state) {
              if (!(state is SingleProfileUninitialized) &&
                  !state.loadedPlayers) {
                bloc.add(SingleProfileLoadPlayers());
              }
              return AnimatedCrossFade(
                duration: Duration(seconds: 3),
                crossFadeState: state.players.length > 0 &&
                        state.players.first.photoUrl.isNotEmpty
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  profile.initials(),
                ),
                secondChild: state.players.length > 0
                    ? CachedNetworkImage(
                        imageUrl: state.players.first.photoUrl,
                      )
                    : Text(""),
              );
            },
          ),
        ),
      ),
    );
  }
}
