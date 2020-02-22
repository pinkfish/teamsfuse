import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'cachednetworkimage.dart';

///
/// Displays the user image.
///
class UserImage extends StatelessWidget {
  UserImage(
    this.profile, {
    Key key,
    this.radius = 20.0,
    this.backgroundColor,
  }) : super(key: key);

  final FusedUserProfile profile;
  final double radius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    var bloc = SingleUserBloc(
        userUid: profile.uid,
        databaseUpdateModel:
            BlocProvider.of<CoordinationBloc>(context).databaseUpdateModel);
    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: radius,
      child: BlocProvider(
        create: (BuildContext context) => bloc,
        child: BlocBuilder(
          bloc: bloc,
          builder: (BuildContext context, SingleUserState state) {
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
    );
  }
}
