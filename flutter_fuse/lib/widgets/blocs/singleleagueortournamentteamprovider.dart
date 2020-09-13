import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'base/singleprovider.dart';

typedef SingleLeagueOrTournamentTeamProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentTeamBloc singleLeagueOrTournamentTeamBloc);

///
///  Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
/// bloc is not current provided or is different than the leagueOrTournamentTeamuid.
///
class SingleLeagueOrTournamentTeamProvider
    extends SingleBlocProvider<SingleLeagueOrTournamentTeamBloc> {
  SingleLeagueOrTournamentTeamProvider(
      {String leagueTeamUid,
      SingleLeagueOrTournamentTeamProviderBuilder builder})
      : super(keyUid: leagueTeamUid, creator: _createBloc, builder: builder);

  static SingleLeagueOrTournamentTeamBloc _createBloc(
      BuildContext context, String uid) {
    return SingleLeagueOrTournamentTeamBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        leagueTeamUid: uid);
  }
}
