import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// Builder to make the @SingleLeagueOrTournamentTeamBloc from the input
/// stuff.
///
typedef SingleLeagueOrTournamentTeamProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentTeamBloc singleLeagueOrTournamentTeamBloc);

///
///  Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
/// bloc is not current provided or is different than the leagueOrTournamentTeamuid.
///
class SingleLeagueOrTournamentTeamProvider
    extends SingleBlocProvider<SingleLeagueOrTournamentTeamBloc> {
  /// Constructor.
  SingleLeagueOrTournamentTeamProvider(
      {String leagueTeamUid,
      SingleLeagueOrTournamentTeamProviderBuilder builder})
      : super(
            keyUid: leagueTeamUid,
            creator: _createBloc,
            builder: builder,
            prefix: "leagueT");

  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleLeagueOrTournamentTeamBloc &&
        bloc.leagueTeamUid == keyUid);
  }

  static SingleLeagueOrTournamentTeamBloc _createBloc(
      BuildContext context, String uid) {
    return SingleLeagueOrTournamentTeamBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
        leagueTeamUid: uid);
  }
}
