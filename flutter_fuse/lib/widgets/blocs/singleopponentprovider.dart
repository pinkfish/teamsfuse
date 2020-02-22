import 'package:flutter/material.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

///
///The builder for the single teamOpponent bloc.
///
typedef SingleOpponentProviderBuilder = Widget Function(
    BuildContext context, SingleOpponentBloc singleTeamOpponentBloc);

///
/// Create a provider that will insert the singe teamOpponent bloc into the tree if the
/// bloc is not current provided or is different than the teamOpponentuid.
///
class SingleOpponentProvider extends SingleBlocProvider<SingleOpponentBloc> {
  SingleOpponentProvider(
      {String opponentUid,
      SingleTeamBloc singleTeamBloc,
      SingleOpponentProviderBuilder builder})
      : super(
            keyUid: opponentUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, singleTeamBloc, uid),
            builder: builder);

  static SingleOpponentBloc _createBloc(
      BuildContext context, SingleTeamBloc singleTeamBloc, String uid) {
    return SingleOpponentBloc(singleTeamBloc: singleTeamBloc, opponentUid: uid);
  }
}
