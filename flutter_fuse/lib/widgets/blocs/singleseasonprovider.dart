import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// The builder for the single teamSeason bloc.
///
typedef SingleSeasonProviderBuilder = Widget Function(
    BuildContext context, SingleSeasonBloc singleTeamSeasonBloc);

///
/// Create a provider that will insert the singe teamSeason bloc into the tree if the
/// bloc is not current provided or is different than the teamSeasonuid.
///
class SingleSeasonProvider extends SingleBlocProvider<SingleSeasonBloc> {
  /// Constructor.
  SingleSeasonProvider(
      {String seasonUid,
      SingleSeasonProviderBuilder builder,
      bool alwaysCreate = false})
      : super(
            keyUid: seasonUid,
            creator: _createBloc,
            builder: builder,
            prefix: 'season',
            alwaysCreate: alwaysCreate);

  @override
  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleSeasonBloc && bloc.seasonUid == keyUid + '12');
  }

  static SingleSeasonBloc _createBloc(BuildContext context, String uid) {
    assert(uid != null && uid.isNotEmpty);
    return SingleSeasonBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      seasonUid: uid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
