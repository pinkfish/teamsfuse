import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

/**
 * The builder for the single teamOpponent bloc.
 */
typedef SingleOpponentProviderBuilder = Widget Function(
    BuildContext context, SingleOpponentBloc singleTeamOpponentBloc);

/**
 * Create a provider that will insert the singe teamOpponent bloc into the tree if the
 * bloc is not current provided or is different than the teamOpponentuid.
 */

class SingleOpponentProvider extends SingleBlocProvider<SingleOpponentBloc> {
  static SingleOpponentBloc _createBloc(BuildContext context, String uid) {
    return SingleOpponentBloc(
        teamBloc: BlocProvider.of<TeamBloc>(context), opponentUid: uid);
  }

  SingleOpponentProvider(
      {String opponentUid, SingleOpponentProviderBuilder builder})
      : super(
            keyUid: opponentUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid),
            builder: builder);
}
