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
class SingleLeagueOrTournamentSeasonProvider extends StatefulWidget {
  final String leagueOrTournamentSeasonUid;
  final SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc;
  final SingleLeagueOrTournamentSeasonProviderBuilder builder;

  SingleLeagueOrTournamentSeasonProvider(
      {@required this.leagueOrTournamentSeasonUid,
      @required this.singleLeagueOrTournamentBloc,
      @required this.builder});

  @override
  State createState() => _SingleLeagueOrTournamentSeasonProviderState();
}

class _SingleLeagueOrTournamentSeasonProviderState
    extends State<SingleLeagueOrTournamentSeasonProvider> {
  SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleLeagueOrTournamentSeasonBloc =
        BlocProvider.of<SingleLeagueOrTournamentSeasonBloc>(context);
    if (singleLeagueOrTournamentSeasonBloc == null ||
        singleLeagueOrTournamentSeasonBloc.leagueSeasonUid !=
            widget.leagueOrTournamentSeasonUid) {
      singleLeagueOrTournamentSeasonBloc = SingleLeagueOrTournamentSeasonBloc(
          singleLeagueOrTournamentBloc: widget.singleLeagueOrTournamentBloc,
          leagueSeasonUid: widget.leagueOrTournamentSeasonUid);

      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleLeagueOrTournamentSeasonBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleLeagueOrTournamentSeasonBloc,
        child: widget.builder(context, singleLeagueOrTournamentSeasonBloc),
      );
    }
    return widget.builder(context, singleLeagueOrTournamentSeasonBloc);
  }
}
