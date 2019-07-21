import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SinglePlayerProviderBuilder = Widget Function(
    BuildContext context, SinglePlayerBloc singlePlayerBloc);

/**
 * Create a provider that will insert the singe player bloc into the tree if the
 * bloc is not current provided or is different than the playeruid.
 */
class SinglePlayerProvider extends StatelessWidget {
  final String playerUid;
  final SinglePlayerProviderBuilder builder;

  SinglePlayerProvider({@required this.playerUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singlePlayerBloc = BlocProvider.of<SinglePlayerBloc>(context);
    if (singlePlayerBloc == null || singlePlayerBloc.playerUid != playerUid) {
      singlePlayerBloc = SinglePlayerBloc(
          playerBloc: BlocProvider.of<PlayerBloc>(context),
          playerUid: playerUid);
      return BlocProvider(
        builder: (BuildContext context) => singlePlayerBloc,
        child: builder(context, singlePlayerBloc),
      );
    }
    return builder(context, singlePlayerBloc);
  }
}
