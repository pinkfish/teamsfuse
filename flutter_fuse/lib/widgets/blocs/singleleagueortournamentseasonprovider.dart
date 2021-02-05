import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

typedef SingleLeagueOrTournamentSeasonProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc);

///
/// Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
/// bloc is not current provided or is different than the leagueOrTournamentTeamuid.
///
class SingleLeagueOrTournamentSeasonProvider
    extends SingleBlocProvider<SingleLeagueOrTournamentSeasonBloc> {
  /// Constructor.
  SingleLeagueOrTournamentSeasonProvider({
    String leagueSeasonUid,
    SingleLeagueOrTournamentSeasonProviderBuilder builder,
  }) : super(
            keyUid: leagueSeasonUid,
            creator: _createBloc,
            builder: builder,
            prefix: "leagueS");

  static SingleLeagueOrTournamentSeasonBloc _createBloc(
      BuildContext context, String uid) {
    return SingleLeagueOrTournamentSeasonBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
        leagueSeasonUid: uid);
  }
}
