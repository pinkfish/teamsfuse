import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

/**
 * The builder for the single teamSeason bloc.
 */
typedef SingleTeamSeasonPlayerProviderBuilder = Widget Function(
    BuildContext context, SingleTeamSeasonPlayerBloc singleTeamSeasonBloc);

/**
 * Create a provider that will insert the singe teamSeason bloc into the tree if the
 * bloc is not current provided or is different than the teamSeasonuid.
 */

class SingleTeamSeasonPlayerProvider
    extends SingleBlocProvider<SingleTeamSeasonPlayerBloc> {
  static SingleTeamSeasonPlayerBloc _createBloc(
      BuildContext context, String uid, String teamUid, String seasonUid) {
    return SingleTeamSeasonPlayerBloc(
        teamBloc: BlocProvider.of<TeamBloc>(context),
        teamUid: teamUid,
        seasonUid: seasonUid,
        playerUid: uid);
  }

  SingleTeamSeasonPlayerProvider(
      {String seasonUid,
      String teamUid,
      String playerUid,
      SingleTeamSeasonPlayerProviderBuilder builder})
      : super(
            keyUid: playerUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid, teamUid, seasonUid),
            builder: builder);
}
