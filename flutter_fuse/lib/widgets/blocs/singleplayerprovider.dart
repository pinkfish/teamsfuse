import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SinglePlayerProviderBuilder = Widget Function(
    BuildContext context, SinglePlayerBloc singlePlayerBloc);

/**
 * Create a provider that will insert the singe player bloc into the tree if the
 * bloc is not current provided or is different than the playeruid.
 */
class SinglePlayerProvider extends StatefulWidget {
  final String playerUid;
  final SinglePlayerProviderBuilder builder;

  SinglePlayerProvider({@required this.playerUid, @required this.builder});

  @override
  State createState() => _SinglePlayerProviderState();
}

class _SinglePlayerProviderState extends State<SinglePlayerProvider> {
  SinglePlayerBloc singlePlayerBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singlePlayerBloc = BlocProvider.of<SinglePlayerBloc>(context);
    if (singlePlayerBloc == null ||
        singlePlayerBloc.playerUid != widget.playerUid) {
      singlePlayerBloc = SinglePlayerBloc(
          playerBloc: BlocProvider.of<PlayerBloc>(context),
          playerUid: widget.playerUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singlePlayerBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singlePlayerBloc,
        child: widget.builder(context, singlePlayerBloc),
      );
    }
    return widget.builder(context, singlePlayerBloc);
  }
}
