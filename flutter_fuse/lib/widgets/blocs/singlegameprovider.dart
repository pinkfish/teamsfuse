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
class SingleGameProvider extends StatelessWidget {
  final String gameUid;
  final SingleGameProviderBuilder builder;

  SingleGameProvider({@required this.gameUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    SingleGameBloc singleGameBloc = BlocProvider.of<SingleGameBloc>(context);
    if (singleGameBloc == null || singleGameBloc.gameUid != gameUid) {
      singleGameBloc = SingleGameBloc(
          gameBloc: BlocProvider.of<GameBloc>(context), gameUid: gameUid);
      return BlocProvider(
        builder: (BuildContext context) => singleGameBloc,
        child: builder(context, singleGameBloc),
      );
    }
    return builder(context, singleGameBloc);
  }
}
