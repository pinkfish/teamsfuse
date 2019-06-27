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
class SingleLeagueOrTournamentDivisonProvider extends StatefulWidget {
  final String leagueOrTournamentDivisonUid;
  final SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc;
  final SingleLeagueOrTournamentDivisonProviderBuilder builder;

  SingleLeagueOrTournamentDivisonProvider(
      {@required this.leagueOrTournamentDivisonUid,
      @required this.singleLeagueOrTournamentSeasonBloc,
      @required this.builder});

  @override
  State createState() => _SingleLeagueOrTournamentDivisonProviderState();
}

class _SingleLeagueOrTournamentDivisonProviderState
    extends State<SingleLeagueOrTournamentDivisonProvider> {
  SingleLeagueOrTournamentDivisonBloc singleLeagueOrTournamentDivisonBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleLeagueOrTournamentDivisonBloc =
        BlocProvider.of<SingleLeagueOrTournamentDivisonBloc>(context);
    if (singleLeagueOrTournamentDivisonBloc == null ||
        singleLeagueOrTournamentDivisonBloc.leagueDivisonUid !=
            widget.leagueOrTournamentDivisonUid) {
      singleLeagueOrTournamentDivisonBloc = SingleLeagueOrTournamentDivisonBloc(
          singleLeagueOrTournamentSeasonBloc:
              widget.singleLeagueOrTournamentSeasonBloc,
          leagueDivisonUid: widget.leagueOrTournamentDivisonUid);

      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleLeagueOrTournamentDivisonBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleLeagueOrTournamentDivisonBloc,
        child: widget.builder(context, singleLeagueOrTournamentDivisonBloc),
      );
    }
    return widget.builder(context, singleLeagueOrTournamentDivisonBloc);
  }
}
