import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

typedef SinglePlayerProviderBuilder = Widget Function(
    BuildContext context, SinglePlayerBloc singlePlayerBloc);

///
/// Create a provider that will insert the singe player bloc into the tree if the
/// bloc is not current provided or is different than the playeruid.
///

class SinglePlayerProvider extends SingleBlocProvider<SinglePlayerBloc> {
  /// Constructor.
  SinglePlayerProvider({String playerUid, SinglePlayerProviderBuilder builder})
      : super(keyUid: playerUid, creator: _createBloc, builder: builder);

  static SinglePlayerBloc _createBloc(BuildContext context, String uid) {
    return SinglePlayerBloc(
        playerBloc: BlocProvider.of<PlayerBloc>(context), playerUid: uid);
  }
}
