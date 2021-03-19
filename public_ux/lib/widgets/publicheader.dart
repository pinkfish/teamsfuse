import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleclubprovider.dart';
import 'package:flutter_fuse/widgets/clubs/clubimage.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// The screen showing all the details of the club.
///
class PublicHeader extends StatelessWidget {
  /// Constructor.
  PublicHeader(this.clubUid);

  /// Club id to show the details for.
  final String clubUid;

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: clubUid,
      builder: (context, singleClubBloc) => BlocBuilder(
        bloc: singleClubBloc,
        builder: (context, singleClubState) {
          if (singleClubState is SingleClubUninitialized) {
            return Text("Loading the club details");
          }
          if (singleClubState is SingleClubDeleted) {
            return Text("This club is deleted?");
          }
          return Row(children: [
            ClubImage(
              clubUid: clubUid,
              width: 50,
              height: 50,
            ),
            Text(singleClubState.club?.name ?? "Womble?",
                style: Theme.of(context).textTheme.headline4),
          ]);
        },
      ),
    );
  }
}
