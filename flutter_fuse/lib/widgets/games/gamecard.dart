import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';

class GameCard extends StatelessWidget {
  Game game;
  Map<Player, Attendance> attendence = new Map<Player, Attendance>();

  GameCard(this.game);

  void _openAttendance(BuildContext context) async {
    if (attendence.length == 1) {
      // Do a simple picker popup.
      ThemeData theme = Theme.of(context);
      Player player = attendence.keys.first;
      Attendance current = attendence[player];

      Attendance attend = await showDialog<Attendance>(
          context: context,
          child: new SimpleDialog(
              title: new Text(Messages.of(context).attendanceselect),
              children: <Widget>[
                new SimpleDialogOption(
                  child: new ListTile(
                    leading: new Icon(Icons.check, color: theme.accentColor),
                    title: new Text(Messages.of(context).attendanceyes),
                    dense: true,
                    selected: current == Attendance.Yes,
                  ),
                  onPressed: () {
                    Navigator.pop(context, Attendance.Yes);
                  },
                ),
                new Divider(),
                new SimpleDialogOption(
                  child: new ListTile(
                    leading: new Icon(Icons.clear, color: theme.errorColor),
                    title: new Text(Messages.of(context).attendanceno),
                    dense: true,
                    selected: current == Attendance.No,
                  ),
                  onPressed: () {
                    Navigator.pop(context, Attendance.No);
                  },
                ),
                new Divider(),
                new SimpleDialogOption(
                  child: new ListTile(
                    leading: new Icon(Icons.help, color: theme.disabledColor),
                    title: new Text(Messages.of(context).attendncemaybe),
                    dense: true,
                    selected: current == Attendance.Maybe,
                  ),
                  onPressed: () {
                    Navigator.pop(context, Attendance.Maybe);
                  },
                )
              ]));
      if (attend != null) {
        game.updateFirestoreAttendence(player.uid, attend);
      }
    } else {
      Map<Player, Attendance> attend = await showDialog(
          context: context, child: new MultipleAttendanceDialog(attendence));
      if (attend != null) {
        attend.forEach((Player player, Attendance attend) {
          game.updateFirestoreAttendence(player.uid, attend);
        });
      }
    }
  }

  Widget _buildAvailability(BuildContext context) {
    print('${game.seasonUid} ${game.teamUid}');
    if (!UserDatabaseData.instance.teams.containsKey(game.teamUid)) {
      return null;
    }
    if (!UserDatabaseData.instance.teams[game.teamUid].seasons
        .containsKey(game.seasonUid)) {
      return null;
    }

    Season season =
        UserDatabaseData.instance.teams[game.teamUid].seasons[game.seasonUid];
    // Show current availability.
    UserDatabaseData.instance.players.forEach((String key, Player player) {
      if (season.players.any((SeasonPlayer play) {
        return play.playerUid == key;
      })) {
        if (game.attendance.containsKey(key)) {
          attendence[player] = game.attendance[key];
        } else {
          attendence[player] = Attendance.Maybe;
        }
      }
    });
    if (attendence.length == 0) {
      return null;
    }
    List<Widget> widgets = new List<Widget>();
    ThemeData theme = Theme.of(context);
    attendence.forEach((Player player, Attendance attend) {
      switch (attend) {
        case Attendance.Yes:
          widgets.add(new Icon(Icons.check, color: theme.accentColor));
          break;
        case Attendance.No:
          widgets.add(new Icon(Icons.clear, color: theme.errorColor));
          break;
        case Attendance.Maybe:
          widgets.add(new Icon(Icons.help, color: theme.disabledColor));
          break;
      }
    });
    return new FlatButton(
        onPressed: () {
          this._openAttendance(context);
        },
        child: new Column(children: widgets));
  }

  Widget build(BuildContext context) {
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent op = team.opponents[game.opponentUid];
    String opName;
    if (op == null) {
      opName = Messages.of(context).unknown;
    } else {
      opName = op.name;
    }
    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    String format = MaterialLocalizations.of(context).formatTimeOfDay(day);

    return new Card(
        child: new FlatButton(
      onPressed: () {
        Navigator.pushNamed(context, "/Game/" + game.uid);
      },
      child: new ListTile(
        leading: new TeamImage(game.teamUid),
        title: new Row(
          children: <Widget>[
            new Text(format + ' vs ',
                style: new TextStyle(fontWeight: FontWeight.bold)),
            new Text(opName)
          ],
        ),
        subtitle: new Text(game.place.address),
        trailing: _buildAvailability(context),
      ),
    ));
  }
}
