import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleplayerprovider.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Image of the specific player.  Will make an oval clip rect of the specific
/// radius and fill the image to fit that circle.
///
class PlayerImage extends StatelessWidget {
  /// Constructor.
  PlayerImage(
      {@required this.playerUid,
      Key key,
      this.backgroundColor,
      this.radius = 20.0})
      : assert(playerUid != null),
        super(key: key);

  /// Radius of the circle to put the player image inside.
  final double radius;

  /// Background color of the circle.
  final Color backgroundColor;

  /// The playerUid to lookup.
  final String playerUid;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      key: key,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SinglePlayerProvider(
            playerUid: playerUid,
            builder: (context, bloc) => BlocBuilder(
                cubit: bloc,
                builder: (BuildContext context, SinglePlayerState state) {
                  ImageProvider image;
                  if (state is SinglePlayerUninitialized ||
                      state is SinglePlayerDeleted ||
                      state.player.photoUrl == null) {
                    image = AssetImage('assets/images/defaultavatar2.png');
                  } else {
                    image = CachedNetworkImageProvider(state.player.photoUrl);
                  }
                  return FadeInImage(
                      placeholder:
                          AssetImage('assets/images/defaultavatar2.png'),
                      image: image);
                }),
          ),
        ),
      ),
    );
  }
}
