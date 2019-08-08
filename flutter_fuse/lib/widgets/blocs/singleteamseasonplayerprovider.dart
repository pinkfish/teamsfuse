import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * The builder for the single teamSeason bloc.
 */
typedef SingleTeamSeasonPlayerProviderBuilder = Widget Function(
    BuildContext context, SingleTeamSeasonPlayerBloc singleTeamSeasonBloc);

/**
 * Create a provider that will insert the singe teamSeason bloc into the tree if the
 * bloc is not current provided or is different than the teamSeasonuid.
 */
class SingleTeamSeasonPlayerProvider extends StatelessWidget {
  final String seasonUid;
  final String teamUid;
  final String playerUid;
  final SingleTeamSeasonPlayerProviderBuilder builder;

  SingleTeamSeasonPlayerProvider(
      {@required this.seasonUid,
      @required this.teamUid,
      @required this.playerUid,
      @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleTeamSeasonBloc =
        BlocProvider.of<SingleTeamSeasonPlayerBloc>(context);
    if (singleTeamSeasonBloc == null ||
        singleTeamSeasonBloc.seasonUid != seasonUid) {
      singleTeamSeasonBloc = SingleTeamSeasonPlayerBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context),
          teamUid: teamUid,
          seasonUid: seasonUid,
          playerUid: playerUid);
      return BlocProvider(
        builder: (BuildContext context) => singleTeamSeasonBloc,
        child: builder(context, singleTeamSeasonBloc),
      );
    }
    return builder(context, singleTeamSeasonBloc);
  }
}
