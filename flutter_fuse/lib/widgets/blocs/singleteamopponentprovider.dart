import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

/**
 * The builder for the single teamOpponent bloc.
 */
typedef SingleTeamOpponentProviderBuilder = Widget Function(
    BuildContext context, SingleTeamOpponentBloc singleTeamOpponentBloc);

/**
 * Create a provider that will insert the singe teamOpponent bloc into the tree if the
 * bloc is not current provided or is different than the teamOpponentuid.
 */

class SingleTeamOpponentProvider
    extends SingleBlocProvider<SingleTeamOpponentBloc> {
  static SingleTeamOpponentBloc _createBloc(
      BuildContext context, String uid, String teamUid) {
    return SingleTeamOpponentBloc(
        teamBloc: BlocProvider.of<TeamBloc>(context),
        teamUid: teamUid,
        opponentUid: uid);
  }

  SingleTeamOpponentProvider(
      {String opponentUid,
      String teamUid,
      SingleTeamOpponentProviderBuilder builder})
      : super(
            keyUid: opponentUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid, teamUid),
            builder: builder);
}
