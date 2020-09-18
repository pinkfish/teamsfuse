import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

///
/// Single builder for the club system and happiness.
///
typedef SingleClubProviderBuilder = Widget Function(
    BuildContext context, SingleClubBloc singleClubBloc);

///
/// Create a provider that will insert the singe club bloc into the tree if the
/// bloc is not current provided or is different than the clubuid.
///
class SingleClubProvider extends SingleBlocProvider<SingleClubBloc> {
  /// Constructor.
  SingleClubProvider({String clubUid, SingleClubProviderBuilder builder})
      : super(keyUid: clubUid, creator: _createBloc, builder: builder);

  static SingleClubBloc _createBloc(BuildContext context, String uid) {
    return SingleClubBloc(
        clubBloc: BlocProvider.of<ClubBloc>(context), clubUid: uid);
  }
}
