import 'package:flutter/material.dart';

import '../../services/messagespublic.dart';

///
/// The widget to display the stuff about leagues.
///
class PublicLeagueWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MessagesPublic.of(context).leagueDescription,
            softWrap: true,
            maxLines: 10,
            textScaleFactor: 2.0,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Divider(height: 40),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MessagesPublic.of(context).leagueDetailsResults,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).leagueDetailsGameControl,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).leagueDetailsTeamInterface,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).leagueDetailsLeagueStats,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).leagueDetailsLeagueOlder,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
