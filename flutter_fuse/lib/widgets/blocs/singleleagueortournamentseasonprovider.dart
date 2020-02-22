import 'package:flutter/material.dart';
import 'package:fusemodel/blocs.dart';

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
  SingleLeagueOrTournamentSeasonProvider(
      {String leagueSeasonUid,
      SingleLeagueOrTournamentSeasonProviderBuilder builder,
      SingleLeagueOrTournamentBloc tournmentBloc})
      : super(
            keyUid: leagueSeasonUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid, tournmentBloc),
            builder: builder);

  static SingleLeagueOrTournamentSeasonBloc _createBloc(BuildContext context,
      String uid, SingleLeagueOrTournamentBloc tournmentBloc) {
    return SingleLeagueOrTournamentSeasonBloc(
        singleLeagueOrTournamentBloc: tournmentBloc, leagueSeasonUid: uid);
  }
}
