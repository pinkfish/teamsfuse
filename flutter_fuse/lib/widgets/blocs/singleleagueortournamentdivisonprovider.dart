import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SingleLeagueOrTournamentDivisonProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentDivisonBloc singleLeagueOrTournamentDivisonBloc);

/**
 * Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
 * bloc is not current provided or is different than the leagueOrTournamentTeamuid.
 */
class SingleLeagueOrTournamentDivisonProvider extends StatelessWidget {
  final String leagueOrTournamentDivisonUid;
  final SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc;
  final SingleLeagueOrTournamentDivisonProviderBuilder builder;

  SingleLeagueOrTournamentDivisonProvider(
      {@required this.leagueOrTournamentDivisonUid,
      @required this.singleLeagueOrTournamentSeasonBloc,
      @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleLeagueOrTournamentDivisonBloc =
        BlocProvider.of<SingleLeagueOrTournamentDivisonBloc>(context);
    if (singleLeagueOrTournamentDivisonBloc == null ||
        singleLeagueOrTournamentDivisonBloc.leagueDivisonUid !=
            leagueOrTournamentDivisonUid) {
      singleLeagueOrTournamentDivisonBloc = SingleLeagueOrTournamentDivisonBloc(
          singleLeagueOrTournamentSeasonBloc:
              singleLeagueOrTournamentSeasonBloc,
          leagueDivisonUid: leagueOrTournamentDivisonUid);
      return BlocProvider(
        builder: (BuildContext context) => singleLeagueOrTournamentDivisonBloc,
        child: builder(context, singleLeagueOrTournamentDivisonBloc),
      );
    }
    return builder(context, singleLeagueOrTournamentDivisonBloc);
  }
}
