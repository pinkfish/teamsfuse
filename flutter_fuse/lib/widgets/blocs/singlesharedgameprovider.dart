import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * The builder for the single sharedGame bloc.
 */
typedef SingleSharedGameProviderBuilder = Widget Function(
    BuildContext context, SingleSharedGameBloc singleSharedGameBloc);

/**
 * Create a provider that will insert the singe sharedGame bloc into the tree if the
 * bloc is not current provided or is different than the sharedGameuid.
 */
class SingleSharedGameProvider extends StatefulWidget {
  final String sharedGameUid;
  final SingleSharedGameProviderBuilder builder;

  SingleSharedGameProvider(
      {@required this.sharedGameUid, @required this.builder});

  @override
  State createState() => _SingleSharedGameProviderState();
}

class _SingleSharedGameProviderState extends State<SingleSharedGameProvider> {
  SingleSharedGameBloc singleSharedGameBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleSharedGameBloc = BlocProvider.of<SingleSharedGameBloc>(context);
    if (singleSharedGameBloc == null ||
        singleSharedGameBloc.sharedGameUid != widget.sharedGameUid) {
      singleSharedGameBloc = SingleSharedGameBloc(
          gameBloc: BlocProvider.of<GameBloc>(context),
          gameUid: widget.sharedGameUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleSharedGameBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleSharedGameBloc,
        child: widget.builder(context, singleSharedGameBloc),
      );
    }
    return widget.builder(context, singleSharedGameBloc);
  }
}
