import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

///
///The builder for the single message bloc.
///
typedef SingleMessageProviderBuilder = Widget Function(
    BuildContext context, SingleMessageBloc singleMessageBloc);

///
/// Create a provider that will insert the singe message bloc into the tree if the
/// bloc is not current provided or is different than the messId.
///

class SingleMessageProvider extends SingleBlocProvider<SingleMessageBloc> {
  /// Constructor.
  SingleMessageProvider(
      {String messageId, SingleMessageProviderBuilder builder})
      : super(
            keyUid: messageId,
            creator: _createBloc,
            builder: builder,
            prefix: 'message');

  @override
  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleMessageBloc && bloc.messageUid == keyUid);
  }

  static SingleMessageBloc _createBloc(BuildContext context, String uid) {
    return SingleMessageBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      messageUid: uid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
