import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

/**
 * The builder for the single teamSeason bloc.
 */
typedef SingleTeamSeasonProviderBuilder = Widget Function(
    BuildContext context, SingleTeamSeasonBloc singleTeamSeasonBloc);

/**
 * Create a provider that will insert the singe teamSeason bloc into the tree if the
 * bloc is not current provided or is different than the teamSeasonuid.
 */

class SingleTeamSeasonProvider
    extends SingleBlocProvider<SingleTeamSeasonBloc> {
  static SingleTeamSeasonBloc _createBloc(
      BuildContext context, String uid, String teamUid) {
    return SingleTeamSeasonBloc(
        teamBloc: BlocProvider.of<TeamBloc>(context),
        teamUid: teamUid,
        seasonUid: uid);
  }

  SingleTeamSeasonProvider(
      {String seasonUid,
      String teamUid,
      SingleTeamSeasonProviderBuilder builder})
      : super(
            keyUid: seasonUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid, teamUid),
            builder: builder);
}
