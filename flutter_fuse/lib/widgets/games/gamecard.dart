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
import 'package:fusemodel/src/game/gamefromofficial.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final Map<Player, Attendance> attendence = <Player, Attendance>{};

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
        game.updateFirestoreAttendence(player.uid, attend);
      }
    } else {
      Map<Player, Attendance> attend = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new MultipleAttendanceDialog(attendence);
          });
      if (attend != null) {
        attend.forEach((Player player, Attendance attend) {
          game.updateFirestoreAttendence(player.uid, attend);
        });
      }
    }
  }

  void _editResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new EditResultDialog(game);
      },
    );
  }

  void _officalResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    /*
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new EditResultDialog(game);
      },
    );
    */
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
    print('Attend ${game.uid} $players ${game.attendance} $attendence');
    if (attendence.length == 0) {
      return null;
    }
    List<Widget> widgets = <Widget>[];
    attendence.forEach((Player player, Attendance attend) {
      widgets.add(new AttendanceIcon(attend));
    });
    return new GestureDetector(
      onTap: () {
        _openAttendance(context);
      },
      child: new Column(children: widgets),
    );
  }

  List<Widget> _buildResultColumn(
      BuildContext context,
      GameResultPerPeriod finalResult,
      GameResultPerPeriod overtimeResult,
      GameResultPerPeriod penaltyResult,
      GameResult result) {
    TextStyle style = Theme.of(context).textTheme.body1;
    switch (result) {
      case GameResult.Win:
        style = style.copyWith(color: Theme.of(context).accentColor);
        break;
      case GameResult.Loss:
        style = style.copyWith(color: Theme.of(context).errorColor);
        break;

      case GameResult.Tie:
        style = style.copyWith(color: Colors.blueAccent);
        break;
      case GameResult.Unknown:
        break;
    }
    List<Widget> children = <Widget>[];
    children.add(
      new Text(
        Messages.of(context).gameresult(result),
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
    return children;
  }

  Widget _buildInProgress(BuildContext context) {
    GameFromOfficial officalData =
        GameFromOfficial(game.sharedData, game.leagueOpponentUid);
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
        List<Widget> children = _buildResultColumn(context, finalResult,
            overtimeResult, penaltyResult, game.result.result);
        // If there is an offical result and it is different, mark this.
        if (officalData.isGameFinished) {
          if (!officalData.isSameAs(game.result)) {
            children
                .add(Icon(Icons.error, color: Theme.of(context).errorColor));
          }
        }
        return new Column(
          children: children,
        );
      }
    } else {
      // See if there is an offical result.
      if (officalData.isGameFinished) {
        List<Widget> children = _buildResultColumn(
            context,
            officalData.regulationResult,
            officalData.overtimeResult,
            officalData.penaltyResult,
            officalData.result);
        children.insert(0, Text(Messages.of(context).offical));
        return Column(
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
          Messages.of(context).cardresultinprogress(game.result),
        ),
      ],
    );
  }

  Widget _buildTrailing(
      BuildContext context, Season season, List<Player> players) {
    // Only show attendence until the game/event is over.
    if (game.result.inProgress == GameInProgress.NotStarted) {
      if ((game.trackAttendance &&
          game.sharedData.time >
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
    url += "&destination=" + Uri.encodeComponent(game.sharedData.place.address);
    if (game.sharedData.place.placeId != null) {
      url += "&destionation_place_id=" +
          Uri.encodeComponent(game.sharedData.place.placeId);
    }
    launch(url);
  }

  Widget _buildMain(BuildContext context, LeagueOrTournamentTeam leagueTeam) {
    List<Widget> buttons = <Widget>[];
    Team team;
    //print('Trying ${game.teamUid}');
    if (UserDatabaseData.instance.teams.containsKey(game.teamUid)) {
      team = UserDatabaseData.instance.teams[game.teamUid];
    }
    Opponent op;
    // Use the opponent from the main list before the league one if it is
    // set.
    if (game.sharedData.type == EventType.Game &&
        game.opponentUids.length > 0 &&
        team != null &&
        team.opponents.containsKey(game.opponentUids[0])) {
      op = team.opponents[game.opponentUids[0]];
    } else if (game.sharedData.type == EventType.Game && leagueTeam != null) {
      op = new Opponent(name: leagueTeam.name);
    } else {
      op = new Opponent(name: Messages.of(context).unknown);
    }

    Season season;
    if (team != null) {
      season =
          UserDatabaseData.instance.teams[game.teamUid].seasons[game.seasonUid];
    }
    if (season == null) {
      season = new Season();
    }

    TZDateTime timeNow = new TZDateTime.now(local);
    Duration dur = timeNow.difference(game.sharedData.tzTime).abs();
    TimeOfDay day = new TimeOfDay.fromDateTime(game.sharedData.tzTime);
    String format = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeFormat;
    String tzShortName;
    if (game.sharedData.timezone != local.name) {
      tzShortName = getLocation(game.sharedData.timezone)
          .timeZone(game.sharedData.time.toInt())
          .abbr;
    }

    if (game.sharedData.time != game.sharedData.endTime) {
      TimeOfDay endDay = new TimeOfDay.fromDateTime(game.sharedData.tzEndTime);
      endTimeFormat = MaterialLocalizations.of(context).formatTimeOfDay(endDay);
    }
    String arriveFormat;
    // Only arrival time for games and only if it is before the game.
    if (game.arriveTime != game.sharedData.time &&
        game.sharedData.type == EventType.Game &&
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

    if (game.sharedData.time < new DateTime.now().millisecondsSinceEpoch &&
        game.sharedData.type == EventType.Game &&
        game.result.result == GameResult.Unknown) {
      if (game.sharedData.officialResults != null &&
          game.sharedData.officialResults.result != OfficialResult.InProgress &&
          game.sharedData.officialResults.result != OfficialResult.NotStarted) {
        buttons.add(new FlatButton(
          onPressed: () => _officalResult(context),
          child: new Text(Messages.of(context).useofficialresultbutton),
        ));
      }
      // Show a result button.
      buttons.add(
        new FlatButton(
          onPressed: () => _editResult(context),
          child: new Text(Messages.of(context).addresultbutton),
        ),
      );
    }

    List<TextSpan> subtitle = <TextSpan>[];
    if (arriveFormat != null) {
      String addr = game.sharedData.place.address;
      if (game.sharedData.place.name.isNotEmpty) {
        addr = game.sharedData.place.name;
      }
      subtitle.add(
        new TextSpan(
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(fontWeight: FontWeight.bold),
          text: Messages.of(context).gameaddressarriveat(arriveFormat, addr) +
              "\n",
        ),
      );
    } else {
      if (game.sharedData.place.name.isNotEmpty) {
        subtitle.add(
          new TextSpan(
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold),
            text: game.sharedData.place.name + "\n",
          ),
        );
      } else {
        subtitle.add(
          new TextSpan(
            style: Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold),
            text: game.sharedData.place.address + "\n",
          ),
        );
      }
    }
    List<Player> players = <Player>[];
    if (season != null) {
      players = UserDatabaseData.instance.players.values
          .where((Player p) =>
              season.players.any((SeasonPlayer sp) => sp.playerUid == p.uid))
          .toList();
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

    if (game.sharedData.time < timeNow.millisecondsSinceEpoch &&
        dur.inMinutes < 60) {
      color = Colors.lightBlueAccent;
    }

    switch (game.sharedData.type) {
      case EventType.Game:
        String opName;
        if (op == null) {
          opName = Messages.of(context).unknown;
        } else {
          opName = op.name;
        }
        // Within an hour.
        title = Messages.of(context)
            .gametitle(format, endTimeFormat, tzShortName, opName);

        break;

      case EventType.Event:
        title = Messages.of(context).eventtitle(
            format, game.sharedData.name, endTimeFormat, tzShortName);

        break;

      case EventType.Practice:
        title = Messages.of(context)
            .trainingtitle(format, endTimeFormat, tzShortName);

        break;
    }
    ListTile tile = new ListTile(
      onTap: () {
        Navigator.pushNamed(context, "/Game/" + game.uid);
      },
      leading: new TeamImage(
        team: team,
        width: 50.0,
        height: 50.0,
      ),
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
    );
    if (buttons.length > 0) {
      return new Card(
        color: color,
        child: new Column(
          children: <Widget>[
            tile,
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
        child: tile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (game.leagueOpponentUid != null && game.leagueOpponentUid.isNotEmpty) {
      // Show this in a future.
      return FutureBuilder<LeagueOrTournamentTeam>(
        future: UserDatabaseData.instance.updateModel
            .getLeagueTeamData(game.leagueOpponentUid),
        builder:
            (BuildContext context, AsyncSnapshot<LeagueOrTournamentTeam> team) {
          if (team.hasData) {
            return _buildMain(context, team.data);
          }
          return _buildMain(context, null);
        },
      );
    }
    return _buildMain(context, null);
  }
}
