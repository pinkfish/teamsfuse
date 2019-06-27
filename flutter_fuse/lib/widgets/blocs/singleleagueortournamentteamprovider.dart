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
class SingleLeagueOrTournamentTeamProvider extends StatefulWidget {
  final String leagueOrTournamentTeamUid;
  final SingleLeagueOrTournamentTeamProviderBuilder builder;

  SingleLeagueOrTournamentTeamProvider(
      {@required this.leagueOrTournamentTeamUid, @required this.builder});

  @override
  State createState() => _SingleLeagueOrTournamentTeamProviderState();
}

class _SingleLeagueOrTournamentTeamProviderState
    extends State<SingleLeagueOrTournamentTeamProvider> {
  SingleLeagueOrTournamentTeamBloc singleLeagueOrTournamentTeamBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleLeagueOrTournamentTeamBloc =
        BlocProvider.of<SingleLeagueOrTournamentTeamBloc>(context);
    if (singleLeagueOrTournamentTeamBloc == null ||
        singleLeagueOrTournamentTeamBloc.leagueTeamUid !=
            widget.leagueOrTournamentTeamUid) {
      singleLeagueOrTournamentTeamBloc = SingleLeagueOrTournamentTeamBloc(
          leagueTeamUid: widget.leagueOrTournamentTeamUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleLeagueOrTournamentTeamBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleLeagueOrTournamentTeamBloc,
        child: widget.builder(context, singleLeagueOrTournamentTeamBloc),
      );
    }
    return widget.builder(context, singleLeagueOrTournamentTeamBloc);
  }
}
