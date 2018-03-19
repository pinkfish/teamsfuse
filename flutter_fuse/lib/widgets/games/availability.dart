import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'attendanceicon.dart';
import 'attendancedialog.dart';

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

  void _updateAttendance(SeasonPlayer player, Attendance current) async {
    Attendance attend = await showDialog(
      context: context,
      child: new AttendanceDialog(current: current),
    );
    if (attend != null) {
      widget._game.updateFirestoreAttendence(player.playerUid, attend);
    }
  }

  Widget _buildAvailability(SeasonPlayer player) {
    if (UserDatabaseData.instance.players.containsKey(player.playerUid)) {
      return new GestureDetector(
        onTap: () => _updateAttendance(
              player,
              widget._game.attendance[player.playerUid],
            ),
        child: new AttendanceIcon(
          widget._game.attendance[player.playerUid],
        ),
      );
    }
    return new AttendanceIcon(widget._game.attendance[player.playerUid]);
  }

  Iterable<Widget> _buildChildren() {
    Team team = UserDatabaseData.instance.teams[widget._game.teamUid];
    Season season = team.seasons[widget._game.seasonUid];
    ThemeData theme = Theme.of(context);

    return season.players.map((SeasonPlayer player) {
      bool canEdit =
          UserDatabaseData.instance.players.containsKey(player.playerUid);
      return new ListTile(
        leading: canEdit
            ? new Icon(Icons.person, color: theme.accentColor)
            : const Icon(Icons.person),
        title: new Text(player.displayName),
        trailing: _buildAvailability(player),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ListBody(children: _buildChildren().toList());
  }
}
