import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

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
  SingleLeagueOrTournamentDivisonProvider(
      {String leagueDivisonUid,
      SingleLeagueOrTournamentDivisonProviderBuilder builder,
      SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc})
      : super(
            keyUid: leagueDivisonUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid, singleLeagueOrTournamentSeasonBloc),
            builder: builder);

  static SingleLeagueOrTournamentDivisonBloc _createBloc(
      BuildContext context,
      String uid,
      SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc) {
    return SingleLeagueOrTournamentDivisonBloc(
        coordinationBloc: singleLeagueOrTournamentSeasonBloc == null
            ? BlocProvider.of<CoordinationBloc>(context)
            : null,
        singleLeagueOrTournamentSeasonBloc: singleLeagueOrTournamentSeasonBloc,
        leagueDivisonUid: uid);
  }
}
