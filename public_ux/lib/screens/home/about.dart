import 'package:flutter/material.dart';

import '../../services/messagespublic.dart';

///
/// The widget to display the stuff about things.
///
class PublicAboutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MessagesPublic.of(context).appDescription,
            softWrap: true,
            maxLines: 10,
            textScaleFactor: 2.0,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 40),
                Text(
                  MessagesPublic.of(context).detailsOfflineInformation,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 5),
                Text(
                  MessagesPublic.of(context).detailsMultipleTeamsInformation,
                  textScaleFactor: 1.5,
                  maxLines: 10,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 5),
                Text(
                  MessagesPublic.of(context).detailsLeagueControlInformation,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 5),
                Text(
                  MessagesPublic.of(context).detailsNotificationsInformation,
                  maxLines: 10,
                  textScaleFactor: 1.5,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 5),
                Text(
                  MessagesPublic.of(context).detailsMobileFirstInformation,
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
