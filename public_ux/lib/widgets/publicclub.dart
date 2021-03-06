import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import 'package:flutter_fuse/widgets/clubs/clubimage.dart';

///
/// Shows the details fo the club publically
///
class PublicClub extends StatelessWidget {
  /// Constructor.
  PublicClub(this.club);

  /// The club to show the details for.
  final Club club;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: ClubImage(
              clubUid: club.uid,
              width: (screenSize.width < 500)
                  ? 120.0
                  : (screenSize.width / 4) + 12.0,
              height: screenSize.height / 4 + 20,
            ),
          ),
          Text(
            club.name,
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            club.about,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
