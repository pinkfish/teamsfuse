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
class SingleTeamOpponentProvider extends StatelessWidget {
  final String opponentUid;
  final String teamUid;
  final SingleTeamOpponentProviderBuilder builder;

  SingleTeamOpponentProvider(
      {@required this.opponentUid,
      @required this.teamUid,
      @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleTeamOpponentBloc =
        BlocProvider.of<SingleTeamOpponentBloc>(context);
    if (singleTeamOpponentBloc == null ||
        singleTeamOpponentBloc.opponentUid != opponentUid) {
      singleTeamOpponentBloc = SingleTeamOpponentBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context),
          teamUid: teamUid,
          opponentUid: opponentUid);
      return BlocProvider(
        builder: (BuildContext context) => singleTeamOpponentBloc,
        child: builder(context, singleTeamOpponentBloc),
      );
    }
    return builder(context, singleTeamOpponentBloc);
  }
}
