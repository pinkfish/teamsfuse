import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

typedef SingleLeagueOrTournamentProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc);

///
/// Create a provider that will insert the singe leagueOrTournament bloc into the tree if the
/// bloc is not current provided or is different than the leagueOrTournamentuid.
///
class SingleLeagueOrTournamentProvider
    extends SingleBlocProvider<SingleLeagueOrTournamentBloc> {
  /// Constructor
  SingleLeagueOrTournamentProvider(
      {String leagueUid, SingleLeagueOrTournamentProviderBuilder builder})
      : super(
            keyUid: leagueUid,
            creator: _createBloc,
            builder: builder,
            prefix: 'league');

  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleLeagueOrTournamentBloc && bloc.leagueUid == keyUid);
  }

  static SingleLeagueOrTournamentBloc _createBloc(
      BuildContext context, String uid) {
    return SingleLeagueOrTournamentBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
        leagueUid: uid);
  }
}
