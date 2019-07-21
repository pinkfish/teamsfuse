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
class SingleClubProvider extends StatelessWidget {
  final String clubUid;
  final SingleClubProviderBuilder builder;

  SingleClubProvider({this.clubUid, this.builder});

  @override
  Widget build(BuildContext context) {
    SingleClubBloc singleClubBloc = BlocProvider.of<SingleClubBloc>(context);
    if (singleClubBloc == null || singleClubBloc.clubUid != clubUid) {
      singleClubBloc = SingleClubBloc(
          clubBloc: BlocProvider.of<ClubBloc>(context), clubUid: clubUid);
      return BlocProvider(
        builder: (BuildContext context) => singleClubBloc,
        child: builder(context, singleClubBloc),
      );
    }
    return builder(context, singleClubBloc);
  }
}
