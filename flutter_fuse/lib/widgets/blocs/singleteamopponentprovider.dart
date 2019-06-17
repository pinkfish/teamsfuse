import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * The builder for the single teamOpponent bloc.
 */
typedef SingleTeamOpponentProviderBuilder = Widget Function(
    BuildContext context, SingleTeamOpponentBloc singleTeamOpponentBloc);

/**
 * Create a provider that will insert the singe teamOpponent bloc into the tree if the
 * bloc is not current provided or is different than the teamOpponentuid.
 */
class SingleTeamOpponentProvider extends StatefulWidget {
  final String opponentUid;
  final String teamUid;
  final SingleTeamOpponentProviderBuilder builder;

  SingleTeamOpponentProvider(
      {@required this.opponentUid,
      @required this.teamUid,
      @required this.builder});

  @override
  State createState() => _SingleTeamOpponentProviderState();
}

class _SingleTeamOpponentProviderState
    extends State<SingleTeamOpponentProvider> {
  SingleTeamOpponentBloc singleTeamOpponentBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleTeamOpponentBloc = BlocProvider.of<SingleTeamOpponentBloc>(context);
    if (singleTeamOpponentBloc == null ||
        singleTeamOpponentBloc.opponentUid != widget.opponentUid) {
      singleTeamOpponentBloc = SingleTeamOpponentBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context),
          teamUid: widget.teamUid,
          opponentUid: widget.opponentUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleTeamOpponentBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleTeamOpponentBloc,
        child: widget.builder(context, singleTeamOpponentBloc),
      );
    }
    return widget.builder(context, singleTeamOpponentBloc);
  }
}
