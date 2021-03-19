import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/blocs/single/singleplayerbloc.dart';
import 'package:flutter_fuse/widgets/player/playerimage.dart';

///
/// Show the details for the specific player.
///
class PublicPlayerDetails extends StatelessWidget {
  /// The bloc to get the details from.
  final SinglePlayerBloc bloc;

  /// Create the basic player page.
  PublicPlayerDetails(this.bloc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayerImage(playerUid: bloc.state.player.uid, radius: 100),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bloc.state.player.name,
                    style: Theme.of(context).textTheme.headline2),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
