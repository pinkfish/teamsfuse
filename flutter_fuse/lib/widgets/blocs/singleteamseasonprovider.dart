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
class SingleTeamSeasonProvider extends StatefulWidget {
  final String seasonUid;
  final String teamUid;
  final SingleTeamSeasonProviderBuilder builder;

  SingleTeamSeasonProvider(
      {@required this.seasonUid,
      @required this.teamUid,
      @required this.builder});

  @override
  State createState() => _SingleTeamSeasonProviderState();
}

class _SingleTeamSeasonProviderState extends State<SingleTeamSeasonProvider> {
  SingleTeamSeasonBloc singleTeamSeasonBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleTeamSeasonBloc = BlocProvider.of<SingleTeamSeasonBloc>(context);
    if (singleTeamSeasonBloc == null ||
        singleTeamSeasonBloc.seasonUid != widget.seasonUid) {
      singleTeamSeasonBloc = SingleTeamSeasonBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context),
          teamUid: widget.teamUid,
          seasonUid: widget.seasonUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleTeamSeasonBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleTeamSeasonBloc,
        child: widget.builder(context, singleTeamSeasonBloc),
      );
    }
    return widget.builder(context, singleTeamSeasonBloc);
  }
}
