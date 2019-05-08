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
class SingleLeagueOrTournamentProvider extends StatefulWidget {
  final String leagueOrTournamentUid;
  final SingleLeagueOrTournamentProviderBuilder builder;

  SingleLeagueOrTournamentProvider(
      {@required this.leagueOrTournamentUid, @required this.builder});

  @override
  State createState() => _SingleLeagueOrTournamentProviderState();
}

class _SingleLeagueOrTournamentProviderState
    extends State<SingleLeagueOrTournamentProvider> {
  SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleLeagueOrTournamentBloc =
        BlocProvider.of<SingleLeagueOrTournamentBloc>(context);
    if (singleLeagueOrTournamentBloc == null ||
        singleLeagueOrTournamentBloc.leagueUid !=
            widget.leagueOrTournamentUid) {
      singleLeagueOrTournamentBloc = SingleLeagueOrTournamentBloc(
          leagueOrTournamentBloc:
              BlocProvider.of<LeagueOrTournamentBloc>(context),
          leagueUid: widget.leagueOrTournamentUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleLeagueOrTournamentBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleLeagueOrTournamentBloc,
        child: widget.builder(context, singleLeagueOrTournamentBloc),
      );
    }
    return widget.builder(context, singleLeagueOrTournamentBloc);
  }
}
