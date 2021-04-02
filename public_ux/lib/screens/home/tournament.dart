import 'package:flutter/material.dart';

import '../../services/messagespublic.dart';

///
/// The widget to display the stuff about tournaments.
///
class PublicTournamentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MessagesPublic.of(context).tournamentsDescription,
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
                  MessagesPublic.of(context).tournamentDetailsResults,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).tournamentDetailsTimePlace,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).tournamentDetailsAdditionalDetails,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).tournamentDetailsRanking,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  MessagesPublic.of(context).tournamentDetailsPerTeam,
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
