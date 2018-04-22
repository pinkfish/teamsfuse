import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';
import 'package:flutter_fuse/widgets/games/attendancedialog.dart';
import 'attendanceicon.dart';
import 'package:timezone/timezone.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final Map<Player, Attendance> attendence = new Map<Player, Attendance>();

  GameCard(this.game);

  void _openAttendance(BuildContext context) async {
    if (attendence.length == 1) {
      // Do a simple picker popup.
      Player player = attendence.keys.first;
      Attendance current = attendence[player];

      Attendance attend = await showDialog<Attendance>(
          context: context,
          builder: (BuildContext context) {
            return new AttendanceDialog(current: current);
          });
      if (attend != null) {
        game.updateFirestorAttendence(player.uid, attend);
      }
    } else {
      Map<Player, Attendance> attend = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new MultipleAttendanceDialog(attendence);
          });
      if (attend != null) {
        attend.forEach((Player player, Attendance attend) {
          game.updateFirestorAttendence(player.uid, attend);
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
    attendence.forEach((Player player, Attendance attend) {
      widgets.add(new AttendanceIcon(attend));
    });
    return new GestureDetector(
      onTap: () {
        this._openAttendance(context);
      },
      child: new Column(children: widgets),
    );
  }

  Widget _buildInProgress(BuildContext context) {
    if (game.result.inProgress == GameInProgress.Final) {
      GameResultPerPeriod finalResult = game.result.scores.firstWhere(
          (GameResultPerPeriod p) => p.period == GameInProgress.Final);
      Iterable<GameResultPerPeriod> temp = game.result.scores.where(
          (GameResultPerPeriod p) => p.period == GameInProgress.Overtime);
      GameResultPerPeriod overtimeResult;
      if (temp.isNotEmpty) {
        overtimeResult = temp.first;
      }
      temp = game.result.scores
          .where((GameResultPerPeriod p) => p.period == GameInProgress.Penalty);
      GameResultPerPeriod penaltyResult;
      if (temp.isNotEmpty) {
        overtimeResult = penaltyResult;
      }
      switch (game.result.result) {
        case GameResult.Win:
        case GameResult.Tie:
        case GameResult.Loss:
          List<Widget> children = [];
          children.add(
            new Text(
              Messages.of(context).gameresult(game.result.result),
            ),
          );
          children.add(
            new Text("${finalResult.ptsFor} - ${finalResult.ptsAgainst}"),
          );
          if (overtimeResult != null) {
            children.add(
              new Text(
                  "OT ${overtimeResult.ptsFor} - ${overtimeResult.ptsAgainst}"),
            );
          }
          if (penaltyResult != null) {
            children.add(
              new Text(
                  "PT ${penaltyResult.ptsFor} - ${penaltyResult.ptsAgainst}"),
            );
          }
          return new Column(
            children: children,
          );

        case GameResult.InProgress:
        case GameResult.Unknown:
          // Do the in progress in this case.
          break;
      }
    }
    return new Column(
      children: <Widget>[
        new Text(
          Messages.of(context).gameinprogress(game.result.inProgress),
        ),
        new Text(
          Messages.of(context).resultinprogress(game.result),
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    // Only show attendence until the game/event is over.
    if (game.result.inProgress == GameInProgress.NotStarted &&
        (game.trackAttendance &&
            game.time >
                new DateTime.now()
                    .subtract(new Duration(hours: 2))
                    .millisecondsSinceEpoch)) {
      return _buildAvailability(context);
    }
    if (game.result.inProgress != GameInProgress.NotStarted) {
      return _buildInProgress(context);
    }
    return null;
  }

  Widget build(BuildContext context) {
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent op;
    if (team == null) {
      op = new Opponent(name: Messages.of(context).unknown);
    } else {
      op = team.opponents[game.opponentUid];
    }

    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    String format = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeFormat;
    if (game.time != game.endTime) {
      TimeOfDay endDay = new TimeOfDay.fromDateTime(game.tzEndTime);
      endTimeFormat = MaterialLocalizations.of(context).formatTimeOfDay(endDay);
    }
    String arriveFormat;
    // Only arrival time for games.
    if (game.arriveTime != game.time && game.type == EventType.Game) {
      TimeOfDay arriveDay = new TimeOfDay.fromDateTime(game.tzArriveTime);
      arriveFormat =
          MaterialLocalizations.of(context).formatTimeOfDay(arriveDay);
    }

    TZDateTime time = new TZDateTime.now(local);
    Duration dur = time.difference(game.tzTime).abs();
    String subtitle;
    if (arriveFormat != null) {
      String addr = game.place.address;
      if (game.place.name.isNotEmpty) {
        addr = game.place.name;
      }
      subtitle = Messages.of(context).gameaddressarriveat(arriveFormat, addr);
    } else {
      if (game.place.name.isNotEmpty) {
        subtitle = game.place.name;
      } else {
        subtitle = game.place.address;
      }
    }
    switch (game.type) {
      case EventType.Game:
        String opName;
        if (op == null) {
          opName = Messages.of(context).unknown;
        } else {
          opName = op.name;
        }
        // Within an hour.
        String title;
        if (dur.inMinutes < 60) {
          title =
              Messages.of(context).gametitlenow(format, endTimeFormat, opName);
        } else {
          title = Messages.of(context).gametitle(format, endTimeFormat, opName);
        }
        return new Card(
          color: Colors.green.shade50,
          child: new ListTile(
            onTap: () {
              Navigator.pushNamed(context, "/Game/" + game.uid);
            },
            leading: new TeamImage(game.teamUid),
            title: new Text(
              title,
              overflow: TextOverflow.clip,
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: new Text(subtitle),
            trailing: _buildTrailing(context),
          ),
        );

      case EventType.Event:
        String title;
        if (dur.inMinutes < 60) {
          title = Messages.of(context).eventtitlenow(format, endTimeFormat);
        } else {
          title = Messages.of(context).eventtitle(format, endTimeFormat);
        }

        return new Card(
          color: Colors.blue.shade50,
          child: new ListTile(
            onTap: () {
              Navigator.pushNamed(context, "/Game/" + game.uid);
            },
            leading: new TeamImage(game.teamUid),
            title: new Text(
              title,
              overflow: TextOverflow.clip,
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: new Text(subtitle),
            trailing: _buildTrailing(context),
          ),
        );

      case EventType.Practice:
        String title;
        if (dur.inMinutes < 60) {
          title = Messages.of(context).trainingtitlenow(format, endTimeFormat);
        } else {
          title = Messages.of(context).trainingtitle(format, endTimeFormat);
        }

        return new Card(
          key: new ValueKey(game),
          child: new ListTile(
            onTap: () {
              Navigator.pushNamed(context, "/Game/" + game.uid);
            },
            leading: new TeamImage(game.teamUid),
            title: new Text(
              title,
              overflow: TextOverflow.clip,
              style: new TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: new Text(subtitle),
            trailing: _buildTrailing(context),
          ),
        );
    }
    return null;
  }
}
