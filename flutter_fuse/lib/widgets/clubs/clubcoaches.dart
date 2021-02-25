import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleclubprovider.dart';
import 'coachtile.dart';

///
/// Shows the coaches for the club.
///
class ClubCoaches extends StatelessWidget {
  /// Constructor.
  ClubCoaches(this.clubUid);

  /// The club to show the details for.
  final String clubUid;

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, singleClubBloc) => SingleChildScrollView(
        child: BlocBuilder(
          cubit: singleClubBloc,
          builder: (context, clubState) {
            BuiltList<Coach> coaches;
            if (clubState is SingleClubUninitialized) {
              coaches = null;
            } else {
              if (!clubState.loadedCoaches) {
                singleClubBloc.add(SingleClubLoadCoaches());
              }
              coaches = clubState.coaches;
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (coaches == null ||
                          coaches.isEmpty && !clubState.loadedCoaches
                      ? [Text(Messages.of(context).loading)]
                      : coaches.isEmpty
                          ? [Text(Messages.of(context).noCoaches)]
                          : coaches.map<Widget>((c) => CoachTile(
                                coachUid: c.uid,
                                clubUid: c.clubUid,
                                isAdmin: clubState.club.isAdmin(),
                              )))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
