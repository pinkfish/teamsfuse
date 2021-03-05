import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import 'base/singleprovider.dart';

typedef SingleUserProviderBuilder = Widget Function(
    BuildContext context, SingleProfileBloc singleUserBloc);

///
/// Create a provider that will insert the singe user bloc into the tree if the
/// bloc is not current provided or is different than the useruid.
///
class SingleProfileProvider extends SingleBlocProvider<SingleProfileBloc> {
  /// Constructor.
  SingleProfileProvider({String userUid, SingleUserProviderBuilder builder})
      : super(
            keyUid: userUid,
            creator: _createBloc,
            builder: builder,
            prefix: 'profile');

  bool isBlocEqual(Bloc bloc) {
    return (bloc is SingleProfileBloc && bloc.profileUid == keyUid);
  }

  static SingleProfileBloc _createBloc(BuildContext context, String uid) {
    return SingleProfileBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context),
        profileUid: uid,
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
        playerBloc: BlocProvider.of<PlayerBloc>(context));
  }
}
