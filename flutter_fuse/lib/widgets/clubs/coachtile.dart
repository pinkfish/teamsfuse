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
  final String clubUid;
  final String coachUid;
  final bool isAdmin;

  CoachTile(
      {@required this.clubUid, @required this.coachUid, this.isAdmin = false});

  Widget build(BuildContext context) {
    return SingleClubCoachProvider(
      builder: (context, singleCoachBloc) => LayoutBuilder(
        builder: (context, layout) => BlocBuilder(
          cubit: singleCoachBloc,
          builder: (context, coachState) {
            if (coachState is SingleClubCoachUninitialized) {
              return Card(
                child: Text(Messages.of(context).loading),
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
                  Expanded(
                      child: Text(coachState.about,
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
