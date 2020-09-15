import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamanimatedlist.dart';

///
/// The base screen to display all the details about all the teams.  This page
/// shows a list of teams and the ability to select between them.
///
class TeamHomeScreen extends StatelessWidget {
  void _addTeam(BuildContext context) {
    Navigator.pushNamed(context, "/AddTeam");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context).teams,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TeamAnimatedList(
              archived: false,
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              child: Text(
                Messages.of(context).archivedteams,
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            TeamAnimatedList(
              archived: true,
            ),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text(Messages.of(context).addteam),
                  onPressed: () => _addTeam(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
