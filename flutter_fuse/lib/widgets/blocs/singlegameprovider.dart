import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// The builder for the single game bloc.
///
typedef SingleGameProviderBuilder = Widget Function(
    BuildContext context, SingleGameBloc singleGameBloc);

///
/// Create a provider that will insert the singe game bloc into the tree if the
/// bloc is not current provided or is different than the gameuid.
///
class SingleGameProvider extends SingleBlocProvider<SingleGameBloc> {
  /// Constructor.
  SingleGameProvider({String gameUid, SingleGameProviderBuilder builder})
      : super(
            keyUid: gameUid,
            creator: _createBloc,
            builder: builder,
            prefix: 'game');

  /// is the bloc equal to this one.
  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleGameBloc && bloc.gameUid == keyUid);
  }

  static SingleGameBloc _createBloc(BuildContext context, String uid) {
    return SingleGameBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      gameUid: uid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
