import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'attendanceicon.dart';

class Availaility extends StatefulWidget {
  final Game _game;

  Availaility(this._game);

  @override
  AvailabityState createState() {
    return new AvailabityState();
  }
}

class AvailabityState extends State<Availaility> {

  AvailabityState();

  Iterable<Widget> _buildChildren() {
    Team team = UserDatabaseData.instance.teams[widget._game.teamUid];
    Season season = team.seasons[widget._game.seasonUid];

    return season.players.map((SeasonPlayer player) {
      return new ListTile(
          leading: const Icon(Icons.person),
          title: new Text(player.displayName),
          trailing: new AttendanceIcon(widget._game.attendance[player.playerUid]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ListBody(children: _buildChildren().toList());
  }
}
