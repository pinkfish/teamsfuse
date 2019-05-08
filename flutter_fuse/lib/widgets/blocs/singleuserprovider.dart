import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

typedef SingleUserProviderBuilder = Widget Function(
    BuildContext context, SingleUserBloc singleUserBloc);

/**
 * Create a provider that will insert the singe user bloc into the tree if the
 * bloc is not current provided or is different than the useruid.
 */
class SingleUserProvider extends StatefulWidget {
  final String userUid;
  final SingleUserProviderBuilder builder;

  SingleUserProvider({@required this.userUid, @required this.builder});

  @override
  State createState() => _SingleUserProviderState();
}

class _SingleUserProviderState extends State<SingleUserProvider> {
  SingleUserBloc singleUserBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleUserBloc = BlocProvider.of<SingleUserBloc>(context);
    if (singleUserBloc == null || singleUserBloc.userUid != widget.userUid) {
      singleUserBloc = SingleUserBloc(
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          userUid: widget.userUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleUserBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleUserBloc,
        child: widget.builder(context, singleUserBloc),
      );
    }
    return widget.builder(context, singleUserBloc);
  }
}
