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
class SingleSharedGameProvider extends StatelessWidget {
  final String sharedGameUid;
  final SingleSharedGameProviderBuilder builder;

  SingleSharedGameProvider(
      {@required this.sharedGameUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleSharedGameBloc = BlocProvider.of<SingleSharedGameBloc>(context);
    if (singleSharedGameBloc == null ||
        singleSharedGameBloc.sharedGameUid != sharedGameUid) {
      singleSharedGameBloc = SingleSharedGameBloc(
          gameBloc: BlocProvider.of<GameBloc>(context), gameUid: sharedGameUid);
      return BlocProvider(
        builder: (BuildContext context) => singleSharedGameBloc,
        child: builder(context, singleSharedGameBloc),
      );
    }
    return builder(context, singleSharedGameBloc);
  }
}
