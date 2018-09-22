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
          children: [
            TeamAnimatedList(),
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
