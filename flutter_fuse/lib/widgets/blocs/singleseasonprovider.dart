import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import 'base/singleprovider.dart';

/**
 * The builder for the single teamSeason bloc.
 */
typedef SingleSeasonProviderBuilder = Widget Function(
    BuildContext context, SingleSeasonBloc singleTeamSeasonBloc);

/**
 * Create a provider that will insert the singe teamSeason bloc into the tree if the
 * bloc is not current provided or is different than the teamSeasonuid.
 */

class SingleSeasonProvider extends SingleBlocProvider<SingleSeasonBloc> {
  static SingleSeasonBloc _createBloc(BuildContext context, String uid) {
    return SingleSeasonBloc(
        seasonBloc: BlocProvider.of<SeasonBloc>(context), seasonUid: uid);
  }

  SingleSeasonProvider({String seasonUid, SingleSeasonProviderBuilder builder})
      : super(
            keyUid: seasonUid,
            creator: (BuildContext context, String uid) =>
                _createBloc(context, uid),
            builder: builder);
}
