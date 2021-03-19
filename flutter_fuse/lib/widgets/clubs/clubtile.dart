import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleclubprovider.dart';
import 'clubimage.dart';

///
/// Tile to display information about the club.
///
class ClubTile extends StatelessWidget {
  /// The club uid to display the tile for.
  final String clubUid;

  /// Creates the club tile with fun stuff in it.
  ClubTile({@required this.clubUid}) : assert(clubUid != null);

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, singleClubBloc) => LayoutBuilder(
        builder: (context, layout) => BlocBuilder(
          bloc: singleClubBloc,
          builder: (context, clubState) {
            if (clubState is SingleClubUninitialized) {
              return Card(
                child: Text(Messages.of(context).loading),
              );
            }
            if (clubState is SingleClubDeleted) {
              return Card(
                child: Text(Messages.of(context).clubDeleted),
              );
            }
            return ListTile(
              leading: ClubImage(clubUid: clubUid, width: 50, height: 50),
              title: Text(clubState.club.name,
                  style: Theme.of(context).textTheme.headline5),
            );
          },
        ),
      ),
    );
  }
}
