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
class SingleTeamProvider extends StatefulWidget {
  final String teamUid;
  final SingleTeamProviderBuilder builder;

  SingleTeamProvider({@required this.teamUid, @required this.builder});

  @override
  State createState() => _SingleTeamProviderState();
}

class _SingleTeamProviderState extends State<SingleTeamProvider> {
  SingleTeamBloc singleTeamBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleTeamBloc = BlocProvider.of<SingleTeamBloc>(context);
    if (singleTeamBloc == null || singleTeamBloc.teamUid != widget.teamUid) {
      singleTeamBloc = SingleTeamBloc(
          teamBloc: BlocProvider.of<TeamBloc>(context),
          teamUid: widget.teamUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleTeamBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleTeamBloc,
        child: widget.builder(context, singleTeamBloc),
      );
    }
    return widget.builder(context, singleTeamBloc);
  }
}
