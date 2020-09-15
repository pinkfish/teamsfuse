import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'base/singleprovider.dart';

///
/// The builder for the single team bloc.
///
typedef SingleTeamProviderBuilder = Widget Function(
    BuildContext context, SingleTeamBloc singleTeamBloc);

///
/// Create a provider that will insert the singe team bloc into the tree if the
/// bloc is not current provided or is different than the teamuid.
///
class SingleTeamProvider extends SingleBlocProvider<SingleTeamBloc> {
  SingleTeamProvider({String teamUid, SingleTeamProviderBuilder builder})
      : super(keyUid: teamUid, creator: _createBloc, builder: builder);

  static SingleTeamBloc _createBloc(BuildContext context, String uid) {
    print("Making bloc $uid");
    return SingleTeamBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      teamUid: uid,
    );
  }
}
