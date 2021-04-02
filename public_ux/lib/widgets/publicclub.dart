import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:flutter_fuse/widgets/clubs/clubimage.dart';
import 'package:public_ux/screens/publicclubhome.dart';
import 'package:public_ux/services/messagespublic.dart';

///
/// Shows the details fo the club publically
///
class PublicClub extends StatelessWidget {
  /// Constructor.
  PublicClub(this.club, {this.smallDisplay = false});

  /// The club to show the details for.
  final Club club;

  /// If this is displayed in a small ux.
  final bool smallDisplay;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                  SizedBox(height: 10),
                  MarkdownBody(
                    data: club.about,
                    //style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
          ),
          smallDisplay
              ? ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context,
                          '/Club/'
                          '${PublicClubTab.team.name}'
                          '/${club.uid}'),
                      child: Text(
                        MessagesPublic.of(context).teamsButton,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context,
                          '/Club/'
                          '${PublicClubTab.coaches.name}'
                          '/${club.uid}'),
                      child: Text(
                        MessagesPublic.of(context).coachesButton,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context,
                          '/Club/'
                          '${PublicClubTab.news.name}'
                          '/${club.uid}'),
                      child: Text(
                        MessagesPublic.of(context).newsButton,
                      ),
                    ),
                  ],
                )
              : SizedBox(height: 0),
        ],
      ),
    );
  }
}
