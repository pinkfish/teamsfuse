import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SingleUserProviderBuilder = Widget Function(
    BuildContext context, SingleUserBloc singleUserBloc);

/**
 * Create a provider that will insert the singe user bloc into the tree if the
 * bloc is not current provided or is different than the useruid.
 */
class SingleUserProvider extends StatelessWidget {
  final String userUid;
  final SingleUserProviderBuilder builder;

  SingleUserProvider({@required this.userUid, @required this.builder});

  @override
  Widget build(BuildContext context) {
    var singleUserBloc = BlocProvider.of<SingleUserBloc>(context);
    if (singleUserBloc == null || singleUserBloc.userUid != userUid) {
      singleUserBloc = SingleUserBloc(
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          userUid: userUid);
      return BlocProvider(
        builder: (BuildContext context) => singleUserBloc,
        child: builder(context, singleUserBloc),
      );
    }
    return builder(context, singleUserBloc);
  }
}
