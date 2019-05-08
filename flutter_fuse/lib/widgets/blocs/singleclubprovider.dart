import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

/**
 * Single builder for the club system and happiness.
 */
typedef SingleClubProviderBuilder = Widget Function(
    BuildContext context, SingleClubBloc singleClubBloc);

/**
 * Create a provider that will insert the singe club bloc into the tree if the
 * bloc is not current provided or is different than the clubuid.
 */
class SingleClubProvider extends StatefulWidget {
  final String clubUid;
  final SingleClubProviderBuilder builder;

  SingleClubProvider({@required this.clubUid, @required this.builder});

  @override
  State createState() => _SingleClubProviderState();
}

class _SingleClubProviderState extends State<SingleClubProvider> {
  SingleClubBloc singleClubBloc;
  bool disposeIt = false;

  void initState() {
    super.initState();
    singleClubBloc = BlocProvider.of<SingleClubBloc>(context);
    if (singleClubBloc == null || singleClubBloc.clubUid != widget.clubUid) {
      singleClubBloc = SingleClubBloc(
          clubBloc: BlocProvider.of<ClubBloc>(context),
          clubUid: widget.clubUid);
      disposeIt = true;
    }
  }

  void dispose() {
    super.dispose();
    if (disposeIt) {
      singleClubBloc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (disposeIt) {
      return BlocProvider(
        bloc: singleClubBloc,
        child: widget.builder(context, singleClubBloc),
      );
    }
    return widget.builder(context, singleClubBloc);
  }
}
