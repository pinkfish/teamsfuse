import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';
import 'package:flutter_fuse/widgets/games/attendancedialog.dart';
import 'package:flutter_fuse/widgets/games/editresultdialog.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void _editResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new EditResultDialog(game);
      },
    );
  }

  Widget _buildAvailability(
      BuildContext context, Season season, List<Player> players) {
    print('${game.seasonUid} ${game.teamUid}');
    if (!UserDatabaseData.instance.teams.containsKey(game.teamUid)) {
      return null;
    }
    if (!UserDatabaseData.instance.teams[game.teamUid].seasons
        .containsKey(game.seasonUid)) {
      return null;
    }

    // Show current availability.
    for (Player player in players) {
      if (game.attendance.containsKey(player.uid)) {
        attendence[player] = game.attendance[player.uid];
      } else {
        attendence[player] = Attendance.Maybe;
      }
    }
    print('Attend $players ${game.attendance} $attendence');
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
      GameResultPerPeriod finalResult;
      GameResultPerPeriod overtimeResult;
      GameResultPerPeriod penaltyResult;
      for (GameResultPerPeriod result in game.result.scores.values) {
        switch (result.period.type) {
          case GamePeriodType.Regulation:
            finalResult = result;
            break;
          case GamePeriodType.Overtime:
            overtimeResult = result;
            break;
          case GamePeriodType.Penalty:
            penaltyResult = result;
            break;
          default:
            break;
        }
      }

      if (game.result.result != GameResult.Unknown) {
        TextStyle style = Theme.of(context).textTheme.body1;
        switch (game.result.result) {
          case GameResult.Win:
            style = style.copyWith(color: Theme.of(context).accentColor);
            break;
          case GameResult.Loss:
            style = style.copyWith(color: Theme.of(context).errorColor);
            break;

          case GameResult.Tie:
            style = style.copyWith(color: Theme.of(context).indicatorColor);
            break;
          case GameResult.Unknown:
            break;
        }
        List<Widget> children = [];
        children.add(
          new Text(
            Messages.of(context).gameresult(game.result.result),
            style: style,
          ),
        );
        children.add(
          new Text(
            "${finalResult.score.ptsFor} - ${finalResult.score.ptsAgainst}",
            style: style,
          ),
        );
        if (overtimeResult != null) {
          children.add(
            new Text(
              "OT ${overtimeResult.score.ptsFor} - ${overtimeResult.score.ptsAgainst}",
              style: style,
            ),
          );
        }
        if (penaltyResult != null) {
          children.add(
            new Text(
              "PT ${penaltyResult.score.ptsFor} - ${penaltyResult.score.ptsAgainst}",
              style: style,
            ),
          );
        }
        return new Column(
          children: children,
        );
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

  Widget _buildTrailing(
      BuildContext context, Season season, List<Player> players) {
    // Only show attendence until the game/event is over.
    if (game.result.inProgress == GameInProgress.NotStarted) {
      if ((game.trackAttendance &&
          game.time >
              new DateTime.now()
                  .subtract(new Duration(hours: 2))
                  .millisecondsSinceEpoch)) {
        return _buildAvailability(context, season, players);
      }
    } else if (game.result.inProgress != GameInProgress.NotStarted) {
      return _buildInProgress(context);
    }
    return null;
  }

  void _showDirections(BuildContext context) {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(game.place.address);
    if (game.place.placeId != null) {
      url +=
          "&destionation_place_id=" + Uri.encodeComponent(game.place.placeId);
    }
    launch(url);
  }

  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent op;
    if (team == null || !team.opponents.containsKey(game.opponentUid)) {
      op = new Opponent(name: Messages.of(context).unknown);
    } else {
      op = team.opponents[game.opponentUid];
    }

    List<Player> players = [];
    Season season;
    if (team != null) {
      season =
          UserDatabaseData.instance.teams[game.teamUid].seasons[game.seasonUid];
    }
    if (season == null) {
      season = new Season();
    }

    UserDatabaseData.instance.players.forEach((String key, Player player) {
      if (season.players.any((SeasonPlayer play) {
        return play.playerUid == key;
      })) {
        players.add(player);
      }
    });

    TZDateTime timeNow = new TZDateTime.now(local);
    Duration dur = timeNow.difference(game.tzTime).abs();
    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    String format = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeFormat;
    String tzShortName;
    if (game.timezone != local.name) {
      tzShortName = getLocation(game.timezone).timeZone(game.time).abbr;
    }

    if (game.time != game.endTime) {
      TimeOfDay endDay = new TimeOfDay.fromDateTime(game.tzEndTime);
      endTimeFormat = MaterialLocalizations.of(context).formatTimeOfDay(endDay);
    }
    String arriveFormat;
    // Only arrival time for games and only if it is before the game.
    if (game.arriveTime != game.time &&
        game.type == EventType.Game &&
        timeNow.millisecondsSinceEpoch <
            game.arriveTime + Duration.millisecondsPerHour) {
      TimeOfDay arriveDay = new TimeOfDay.fromDateTime(game.tzArriveTime);
      arriveFormat =
          MaterialLocalizations.of(context).formatTimeOfDay(arriveDay);
    }

    if (game.arriveTime <
            timeNow.millisecondsSinceEpoch + Duration.millisecondsPerHour &&
        game.arriveTime >
            timeNow.millisecondsSinceEpoch - Duration.millisecondsPerHour * 3) {
      // Put in directions buttons.
      buttons.add(
        new FlatButton(
          onPressed: () => _showDirections(context),
          child: new Text(
            Messages.of(context).directionsbuttons,
          ),
        ),
      );
    }

    if (game.time < new DateTime.now().millisecondsSinceEpoch &&
        game.type == EventType.Game &&
        game.result.result == GameResult.Unknown) {
      // Show a result button.
      buttons.add(
        new FlatButton(
          onPressed: () => _editResult(context),
          child: new Text(Messages.of(context).addresultbutton),
        ),
      );
    }

    List<TextSpan> subtitle = [];
    if (arriveFormat != null) {
      String addr = game.place.address;
      if (game.place.name.isNotEmpty) {
        addr = game.place.name;
      }
      subtitle.add(
        new TextSpan(
          style: Theme
              .of(context)
              .textTheme
              .subhead
              .copyWith(fontWeight: FontWeight.bold),
          text: Messages.of(context).gameaddressarriveat(arriveFormat, addr) +
              "\n",
        ),
      );
    } else {
      if (game.place.name.isNotEmpty) {
        subtitle.add(
          new TextSpan(
            style: Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold),
            text: game.place.name + "\n",
          ),
        );
      } else {
        subtitle.add(
          new TextSpan(
            style: Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold),
            text: game.place.address + "\n",
          ),
        );
      }
    }
    for (Player play in players) {
      subtitle.add(
        new TextSpan(
          style: Theme.of(context).textTheme.subhead,
          text: Messages.of(context).nameandteam(team, play),
        ),
      );
    }

    Color color = Colors.white;
    String title;

    if (game.time < timeNow.millisecondsSinceEpoch && dur.inMinutes < 60) {
      color = Colors.lightBlueAccent;
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
        title = Messages
            .of(context)
            .gametitle(format, endTimeFormat, tzShortName, opName);

        break;

      case EventType.Event:
        title = Messages
            .of(context)
            .eventtitle(format, game.name, endTimeFormat, tzShortName);

        break;

      case EventType.Practice:
        title = Messages
            .of(context)
            .trainingtitle(format, endTimeFormat, tzShortName);

        break;
    }
    if (buttons.length > 0) {
      return new Card(
        color: color,
        child: new Column(
          children: <Widget>[
            new ListTile(
              onTap: () {
                Navigator.pushNamed(context, "/Game/" + game.uid);
              },
              leading: new TeamImage(game.teamUid),
              title: new Text(
                title,
                overflow: TextOverflow.clip,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: new RichText(
                text: new TextSpan(
                  style: Theme.of(context).textTheme.subhead,
                  children: subtitle,
                ),
              ),
              trailing: _buildTrailing(context, season, players),
            ),
            new ButtonTheme.bar(
              // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: buttons,
              ),
            ),
          ],
        ),
      );
    } else {
      return new Card(
        color: color,
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
          subtitle: new RichText(
            text: new TextSpan(
              style: Theme.of(context).textTheme.subhead,
              children: subtitle,
            ),
          ),
          trailing: _buildTrailing(context, season, players),
        ),
      );
    }
  }
}
