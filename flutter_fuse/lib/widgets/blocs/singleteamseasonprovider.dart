import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * The builder for the single teamSeason bloc.
 */
typedef SingleTeamSeasonProviderBuilder = Widget Function(
    BuildContext context, SingleTeamSeasonBloc singleTeamSeasonBloc);

/**
 * Create a provider that will insert the singe teamSeason bloc into the tree if the
 * bloc is not current provided or is different than the teamSeasonuid.
 */
class SingleTeamSeasonProvider extends StatelessWidget {
  final String seasonUid;
  final String teamUid;
  final SingleTeamSeasonProviderBuilder builder;

  SingleTeamSeasonProvider(
      {@required this.seasonUid,
      @required this.teamUid,
      @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleTeamSeasonBloc = BlocProvider.of<SingleTeamSeasonBloc>(context);
    if (singleTeamSeasonBloc == null ||
        singleTeamSeasonBloc.seasonUid != seasonUid) {
      singleTeamSeasonBloc = SingleTeamSeasonBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context),
          teamUid: teamUid,
          seasonUid: seasonUid);
      return BlocProvider(
        builder: (BuildContext context) => singleTeamSeasonBloc,
        child: builder(context, singleTeamSeasonBloc),
      );
    }
    return builder(context, singleTeamSeasonBloc);
  }
}
