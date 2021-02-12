import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleclubcoachprovider.dart';
import 'coachimage.dart';

///
/// Tile to display information about the coach.
///
class CoachTile extends StatelessWidget {
  /// The club uid the coach is in.
  final String clubUid;

  /// THe coach uid in the club to display.
  final String coachUid;

  /// If the user is an admin to display admin options.
  final bool isAdmin;

  /// Creates the coach tile with all the needed bits.
  CoachTile(
      {@required this.clubUid, @required this.coachUid, this.isAdmin = false})
      : assert(clubUid != null && coachUid != null);

  Widget build(BuildContext context) {
    return SingleClubCoachProvider(
      coachUid: coachUid,
      clubUid: clubUid,
      builder: (context, singleCoachBloc) => LayoutBuilder(
        builder: (context, layout) => BlocBuilder(
          cubit: singleCoachBloc,
          builder: (context, coachState) {
            if (coachState is SingleClubCoachUninitialized) {
              return Card(
                child: Text(Messages.of(context).loading),
              );
            }
            if (coachState is SingleClubCoachDeleted) {
              return Card(
                child: Text(Messages.of(context).coachDeleted),
              );
            }
            return Card(
              child: Row(
                children: [
                  CoachImage(
                      clubUid: clubUid,
                      coachUid: coachUid,
                      width: 100,
                      height: 100),
                  SizedBox(width: 15),
                  Expanded(
                      child: Text(coachState.coach.about,
                          style: Theme.of(context).textTheme.bodyText1)),
                  isAdmin
                      ? IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => Navigator.of(context)
                              .pushNamed("/Club/Coach/Edit/$clubUid/$coachUid"))
                      : SizedBox(width: 0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
