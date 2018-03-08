import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'attendanceicon.dart';

class Availaility extends StatefulWidget {
  Game _game;

  Availaility(this._game);

  @override
  AvailabityState createState() {
    return new AvailabityState(this._game);
  }
}

class AvailabityState extends State<Availaility> {
  Game _game;

  AvailabityState(this._game);

  Iterable<Widget> _buildChildren() {
    Team team = UserDatabaseData.instance.teams[_game.teamUid];
    Season season = team.seasons[_game.seasonUid];

    return season.players.map((SeasonPlayer player) {
      return new ListTile(
          leading: const Icon(Icons.person),
          title: new Text(player.displayName),
          trailing: new AttendanceIcon(_game.attendance[player.playerUid]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ListBody(children: _buildChildren().toList());
  }
}
