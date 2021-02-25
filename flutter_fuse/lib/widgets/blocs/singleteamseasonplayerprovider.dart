import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// The builder for the single teamSeason bloc.
///
typedef SingleTeamSeasonPlayerProviderBuilder = Widget Function(
    BuildContext context, SingleTeamSeasonPlayerBloc singleTeamSeasonBloc);

///
/// Create a provider that will insert the single teamSeason bloc into the tree if the
/// bloc is not current provided or is different than the teamSeasonuid.
///
class SingleTeamSeasonPlayerProvider
    extends SingleBlocProvider<SingleTeamSeasonPlayerBloc> {
  /// Constructor
  SingleTeamSeasonPlayerProvider(
      {String seasonUid,
      String playerUid,
      SingleTeamSeasonPlayerProviderBuilder builder})
      : super(
            keyUid: playerUid + seasonUid,
            creator: (context, uid) =>
                _createBloc(context, playerUid, seasonUid),
            builder: builder);

  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleTeamSeasonPlayerBloc && bloc.playerUid == keyUid);
  }

  static SingleTeamSeasonPlayerBloc _createBloc(
      BuildContext context, String playerUid, String seasonUid) {
    return SingleTeamSeasonPlayerBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      seasonUid: seasonUid,
      playerUid: playerUid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
