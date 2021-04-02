import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/media/mediacarousel.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';

import '../screens/publicplayer.dart';
import '../screens/publicteam.dart';

///
/// Show the media for the team.
///
class PublicPlayerMedia extends StatelessWidget {
  /// The player bloc to get the data from.
  final SinglePlayerBloc playerBloc;

  /// Create the class with the player bloc.
  PublicPlayerMedia(this.playerBloc);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: playerBloc,
      builder: (context, SinglePlayerState singlePlayerState) {
        if (singlePlayerState is SinglePlayerUninitialized) {
          return LoadingWidget();
        }
        if (singlePlayerState is SinglePlayerDeleted) {
          return DeletedWidget();
        }
        if (!singlePlayerState.loadedMedia) {
          playerBloc.add(SinglePlayerLoadMedia());
          return Row(children: [
            Text(Messages.of(context).noMedia),
            CircularProgressIndicator(),
          ]);
        }
        return MediaCarousel(
          singlePlayerState.media.first,
          allMedia: singlePlayerState.media,
          onPlayerPressed: (playerUid) => Navigator.pushNamed(
              context, '/Player/${PublicPlayerTab.details}/$playerUid'),
          onTeamPressed: (teamUid) => Navigator.pushNamed(
              context, '/Team/${PublicTeamTab.team}/$teamUid'),
        );
      },
    );
  }
}
