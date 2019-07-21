import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SingleLeagueOrTournamentProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc);

/**
 * Create a provider that will insert the singe leagueOrTournament bloc into the tree if the
 * bloc is not current provided or is different than the leagueOrTournamentuid.
 */
class SingleLeagueOrTournamentProvider extends StatelessWidget {
  final String leagueOrTournamentUid;
  final SingleLeagueOrTournamentProviderBuilder builder;

  SingleLeagueOrTournamentProvider(
      {@required this.leagueOrTournamentUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleLeagueOrTournamentBloc =
        BlocProvider.of<SingleLeagueOrTournamentBloc>(context);
    if (singleLeagueOrTournamentBloc == null ||
        singleLeagueOrTournamentBloc.leagueUid != leagueOrTournamentUid) {
      singleLeagueOrTournamentBloc = SingleLeagueOrTournamentBloc(
          leagueOrTournamentBloc:
              BlocProvider.of<LeagueOrTournamentBloc>(context),
          leagueUid: leagueOrTournamentUid);
      return BlocProvider(
        builder: (BuildContext context) => singleLeagueOrTournamentBloc,
        child: builder(context, singleLeagueOrTournamentBloc),
      );
    }
    return builder(context, singleLeagueOrTournamentBloc);
  }
}
