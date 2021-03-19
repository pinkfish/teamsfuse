import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleseasonbloc.dart';
import 'package:flutter_fuse/services/blocs/single/singleteambloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/games/teamresults.dart';
import 'package:flutter_fuse/widgets/player/gendericon.dart';
import 'package:flutter_fuse/widgets/teams/seasonimages.dart';
import 'package:flutter_fuse/widgets/teams/stats/seasonplayerlist.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:flutter_fuse/widgets/util/deleted.dart';
import 'package:flutter_fuse/widgets/util/handsandtrophy.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:public_ux/screens/publicplayer.dart';

///
/// Shows the public details of the team and the current season (only showing
/// the one season).
///
class PublicSeasonPlayers extends StatelessWidget {
  /// Constructor.
  PublicSeasonPlayers(this.singleTeamBloc);

  /// The teamUid to show the details for.
  final SingleTeamBloc singleTeamBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: singleTeamBloc,
      builder: (c, singleTeamState) => SingleSeasonProvider(
        seasonUid: singleTeamState.team.currentSeason,
        builder: (c, singleSeasonBloc) => BlocBuilder(
          bloc: singleSeasonBloc,
          builder: (context, seasonState) {
            if (seasonState is SingleSeasonDeleted) {
              return DeletedWidget();
            }
            if (seasonState is SingleSeasonUninitialized) {
              return LoadingWidget();
            }
            return SeasonPlayerList(
              season: seasonState.season,
              orientation: Orientation.landscape,
              onTap: (pl) => Navigator.pushNamed(
                  context,
                  '/Player/${PublicPlayerTab.details.name}/'
                  '${pl.playerUid}'),
            );
          },
        ),
      ),
    );
  }
}
