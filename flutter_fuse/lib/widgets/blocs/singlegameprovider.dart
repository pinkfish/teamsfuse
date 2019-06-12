import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * The builder for the single game bloc.
 */
typedef SingleGameProviderBuilder = Widget Function(
    BuildContext context, SingleGameBloc singleGameBloc);

/**
 * Create a provider that will insert the singe game bloc into the tree if the
 * bloc is not current provided or is different than the gameuid.
 */
class SingleGameProvider extends StatefulWidget {
  final String gameUid;
  final SingleGameProviderBuilder builder;

  SingleGameProvider({@required this.gameUid, @required this.builder});

  @override
  State createState() => _SingleGameProviderState();
}

class _SingleGameProviderState extends State<SingleGameProvider> {
  SingleGameBloc singleGameBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleGameBloc = BlocProvider.of<SingleGameBloc>(context);
    if (singleGameBloc == null || singleGameBloc.gameUid != widget.gameUid) {
      singleGameBloc = SingleGameBloc(
          gameBloc: BlocProvider.of<GameBloc>(context),
          gameUid: widget.gameUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleGameBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleGameBloc,
        child: widget.builder(context, singleGameBloc),
      );
    }
    return widget.builder(context, singleGameBloc);
  }
}
