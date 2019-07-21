import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SingleLeagueOrTournamentSeasonProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc);

/**
 * Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
 * bloc is not current provided or is different than the leagueOrTournamentTeamuid.
 */
class SingleLeagueOrTournamentSeasonProvider extends StatelessWidget {
  final String leagueOrTournamentSeasonUid;
  final SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc;
  final SingleLeagueOrTournamentSeasonProviderBuilder builder;

  SingleLeagueOrTournamentSeasonProvider(
      {@required this.leagueOrTournamentSeasonUid,
      @required this.singleLeagueOrTournamentBloc,
      @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleLeagueOrTournamentSeasonBloc =
        BlocProvider.of<SingleLeagueOrTournamentSeasonBloc>(context);
    if (singleLeagueOrTournamentSeasonBloc == null ||
        singleLeagueOrTournamentSeasonBloc.leagueSeasonUid !=
            leagueOrTournamentSeasonUid) {
      singleLeagueOrTournamentSeasonBloc = SingleLeagueOrTournamentSeasonBloc(
          singleLeagueOrTournamentBloc: singleLeagueOrTournamentBloc,
          leagueSeasonUid: leagueOrTournamentSeasonUid);
      return BlocProvider(
        builder: (BuildContext context) => singleLeagueOrTournamentSeasonBloc,
        child: builder(context, singleLeagueOrTournamentSeasonBloc),
      );
    }
    return builder(context, singleLeagueOrTournamentSeasonBloc);
  }
}
