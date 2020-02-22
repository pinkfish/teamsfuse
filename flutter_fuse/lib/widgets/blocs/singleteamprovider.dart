import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

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
    return SingleTeamBloc(
        teamBloc: BlocProvider.of<TeamBloc>(context),
        seasonBloc: BlocProvider.of<SeasonBloc>(context),
        teamUid: uid,
        clubBloc: BlocProvider.of<ClubBloc>(context));
  }
}
