import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * The builder for the single team bloc.
 */
typedef SingleTeamProviderBuilder = Widget Function(
    BuildContext context, SingleTeamBloc singleTeamBloc);

/**
 * Create a provider that will insert the singe team bloc into the tree if the
 * bloc is not current provided or is different than the teamuid.
 */
class SingleTeamProvider extends StatelessWidget {
  final String teamUid;
  final SingleTeamProviderBuilder builder;

  SingleTeamProvider({@required this.teamUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleTeamBloc = BlocProvider.of<SingleTeamBloc>(context);
    if (singleTeamBloc == null || singleTeamBloc.teamUid != teamUid) {
      singleTeamBloc = SingleTeamBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context), teamUid: teamUid);
      return BlocProvider(
        builder: (BuildContext context) => singleTeamBloc,
        child: builder(context, singleTeamBloc),
      );
    }
    return builder(context, singleTeamBloc);
  }
}
