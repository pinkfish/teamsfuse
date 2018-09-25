import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/teams/teamanimatedlist.dart';

class TeamHomeScreen extends StatelessWidget {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Widget _addTeam() {}

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
          children: [
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
              children: [
                FlatButton(
                  child: Text(Messages.of(context).addteam),
                  onPressed: _addTeam,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
