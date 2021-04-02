import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/blocs/single/singleteambloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/teams/media/mediacarousel.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:public_ux/screens/publicplayer.dart';
import 'package:public_ux/screens/publicteam.dart';

///
/// Show the media for the team.
///
class PublicTeamMedia extends StatelessWidget {
  final SingleTeamBloc teamBloc;

  /// Create the class with the team bloc.
  PublicTeamMedia(this.teamBloc);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: teamBloc,
      builder: (context, SingleTeamState singleTeamState) {
        return SingleSeasonProvider(
          seasonUid: singleTeamState.team.currentSeason,
          builder: (context, seasonBloc) => BlocBuilder(
            bloc: seasonBloc,
            builder: (context, SingleSeasonState singleSeasonState) {
              if (singleSeasonState is SingleSeasonUninitialized) {
                return LoadingWidget();
              }
              if (singleSeasonState is SingleSeasonDeleted) {
                return DeletedWidget();
              }
              if (!singleSeasonState.loadedMedia) {
                seasonBloc.add(SingleSeasonLoadMedia());
                return Row(children: [
                  Text(Messages.of(context).noMedia),
                  CircularProgressIndicator(),
                ]);
              }
              return MediaCarousel(
                singleSeasonState.media.first,
                allMedia: singleSeasonState.media,
                onPlayerPressed: (playerUid) => Navigator.pushNamed(
                    context, '/Player/${PublicPlayerTab.details}/$playerUid'),
                onTeamPressed: (teamUid) => Navigator.pushNamed(
                    context, '/Team/${PublicTeamTab.team}/$teamUid'),
              );
            },
          ),
        );
      },
    );
  }
}
