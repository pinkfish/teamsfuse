import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

typedef SingleLeagueOrTournamentDivisonProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentDivisonBloc singleLeagueOrTournamentDivisonBloc);

///
/// Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
///bloc is not current provided or is different than the leagueOrTournamentTeamuid.
///
class SingleLeagueOrTournamentDivisonProvider
    extends SingleBlocProvider<SingleLeagueOrTournamentDivisonBloc> {
  /// constructor.
  SingleLeagueOrTournamentDivisonProvider(
      {String leagueDivisonUid,
      SingleLeagueOrTournamentDivisonProviderBuilder builder})
      : super(
            keyUid: leagueDivisonUid,
            creator: (context, uid) => _createBloc(context, uid),
            builder: builder,
            prefix: 'leagueD');

  @override
  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleLeagueOrTournamentDivisonBloc &&
        bloc.leagueDivisonUid == keyUid);
  }

  static SingleLeagueOrTournamentDivisonBloc _createBloc(
      BuildContext context, String uid) {
    return SingleLeagueOrTournamentDivisonBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
        leagueDivisonUid: uid);
  }
}
