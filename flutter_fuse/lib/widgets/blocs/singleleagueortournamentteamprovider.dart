import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SingleLeagueOrTournamentTeamProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentTeamBloc singleLeagueOrTournamentTeamBloc);

/**
 * Create a provider that will insert the singe leagueOrTournamentTeam bloc into the tree if the
 * bloc is not current provided or is different than the leagueOrTournamentTeamuid.
 */
class SingleLeagueOrTournamentTeamProvider extends StatelessWidget {
  final String leagueOrTournamentTeamUid;
  final SingleLeagueOrTournamentTeamProviderBuilder builder;

  SingleLeagueOrTournamentTeamProvider(
      {@required this.leagueOrTournamentTeamUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleLeagueOrTournamentTeamBloc =
        BlocProvider.of<SingleLeagueOrTournamentTeamBloc>(context);
    if (singleLeagueOrTournamentTeamBloc == null ||
        singleLeagueOrTournamentTeamBloc.leagueTeamUid !=
            leagueOrTournamentTeamUid) {
      singleLeagueOrTournamentTeamBloc = SingleLeagueOrTournamentTeamBloc(
          leagueTeamUid: leagueOrTournamentTeamUid);
      return BlocProvider(
        builder: (BuildContext context) => singleLeagueOrTournamentTeamBloc,
        child: builder(context, singleLeagueOrTournamentTeamBloc),
      );
    }
    return builder(context, singleLeagueOrTournamentTeamBloc);
  }
}
