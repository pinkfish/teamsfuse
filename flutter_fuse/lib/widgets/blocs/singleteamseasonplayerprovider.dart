import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

///
/// The builder for the single teamSeason bloc.
///
typedef SingleTeamSeasonPlayerProviderBuilder = Widget Function(
    BuildContext context, SingleTeamSeasonPlayerBloc singleTeamSeasonBloc);

///
/// Create a provider that will insert the singe teamSeason bloc into the tree if the
/// bloc is not current provided or is different than the teamSeasonuid.
///
class SingleTeamSeasonPlayerProvider
    extends SingleBlocProvider<SingleTeamSeasonPlayerBloc> {
  SingleTeamSeasonPlayerProvider(
      {String seasonUid,
      String playerUid,
      SingleTeamSeasonPlayerProviderBuilder builder})
      : super(
            keyUid: playerUid + playerUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, playerUid, seasonUid),
            builder: builder);

  static SingleTeamSeasonPlayerBloc _createBloc(
      BuildContext context, String playerUid, String seasonUid) {
    return SingleTeamSeasonPlayerBloc(
        seasonBloc: BlocProvider.of<SeasonBloc>(context),
        playerBloc: BlocProvider.of<PlayerBloc>(context),
        seasonUid: seasonUid,
        playerUid: playerUid);
  }
}
