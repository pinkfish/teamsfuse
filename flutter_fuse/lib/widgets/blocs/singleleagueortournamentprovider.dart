import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'base/singleprovider.dart';

typedef SingleLeagueOrTournamentProviderBuilder = Widget Function(
    BuildContext context,
    SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc);

///
/// Create a provider that will insert the singe leagueOrTournament bloc into the tree if the
/// bloc is not current provided or is different than the leagueOrTournamentuid.
///
class SingleLeagueOrTournamentProvider
    extends SingleBlocProvider<SingleLeagueOrTournamentBloc> {
  SingleLeagueOrTournamentProvider(
      {String leagueUid, SingleLeagueOrTournamentProviderBuilder builder})
      : super(keyUid: leagueUid, creator: _createBloc, builder: builder);

  static SingleLeagueOrTournamentBloc _createBloc(
      BuildContext context, String uid) {
    return SingleLeagueOrTournamentBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        leagueUid: uid);
  }
}
