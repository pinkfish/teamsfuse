import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
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
  /// Constructor.
  SingleTeamProvider({String teamUid, SingleTeamProviderBuilder builder})
      : super(
            keyUid: teamUid,
            creator: _createBloc,
            builder: builder,
            prefix: "team");

  static SingleTeamBloc _createBloc(BuildContext context, String uid) {
    return SingleTeamBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      teamUid: uid,
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }
}
