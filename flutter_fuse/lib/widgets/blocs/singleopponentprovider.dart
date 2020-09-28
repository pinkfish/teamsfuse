import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

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
  /// Constructor.
  SingleOpponentProvider(
      {String opponentUid,
      String teamUid,
      SingleOpponentProviderBuilder builder})
      : super(
            keyUid: opponentUid,
            creator: (context, uid) => _createBloc(context, teamUid, uid),
            builder: builder);

  static SingleOpponentBloc _createBloc(
      BuildContext context, String teamUid, String uid) {
    return SingleOpponentBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        opponentUid: uid);
  }
}
