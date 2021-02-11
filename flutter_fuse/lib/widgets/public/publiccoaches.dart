import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Shows the details about the coaches in a specific club.
///
class PublicCoachDetails extends StatelessWidget {
  /// The bloc to use to populate the coaches from.
  SingleClubBloc bloc;

  /// The constructor.
  PublicCoachDetails(this.bloc);

  Widget build(BuildContext context) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          if (!state.loadedCoaches) {
            bloc.add(SingleClubLoadCoaches());
          }
          if (state is SingleClubUninitialized || !state.loadedCoaches) {
            return Text(Messages.of(context).loading);
          }
          if (state is SingleClubDeleted) {
            return Text(Messages.of(context).clubDeleted);
          }
          if (state.coaches.isEmpty) {
            return Text(Messages.of(context).noCoaches);
          }
        });
  }
}
