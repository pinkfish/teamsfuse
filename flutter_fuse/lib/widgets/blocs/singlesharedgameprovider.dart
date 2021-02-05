import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
/// The builder for the single sharedGame bloc.
///
typedef SingleSharedGameProviderBuilder = Widget Function(
    BuildContext context, SingleSharedGameBloc singleSharedGameBloc);

///
/// Create a provider that will insert the singe sharedGame bloc into the tree if the
/// bloc is not current provided or is different than the sharedGameuid.
///
class SingleSharedGameProvider
    extends SingleBlocProvider<SingleSharedGameBloc> {
  /// Constructor
  SingleSharedGameProvider(
      {String sharedGameUid, SingleSharedGameProviderBuilder builder})
      : super(
            keyUid: sharedGameUid,
            creator: _createBloc,
            builder: builder,
            prefix: "shared");

  static SingleSharedGameBloc _createBloc(BuildContext context, String uid) {
    return SingleSharedGameBloc(
      gameBloc: BlocProvider.of<GameBloc>(context),
      sharedGameUid: uid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
