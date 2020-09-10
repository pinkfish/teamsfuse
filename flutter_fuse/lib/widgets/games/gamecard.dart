import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/attendancedialog.dart';
import 'package:flutter_fuse/widgets/games/editresultdialog.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/game/gamefromofficial.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/singlegameprovider.dart';
import '../blocs/singleleagueortournamentteamprovider.dart';
import '../blocs/singleopponentprovider.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import 'attendanceicon.dart';

class GameCard extends StatelessWidget {
  GameCard({@required this.gameUid, this.singleGameBloc});

  final String gameUid;
  final SingleGameBloc singleGameBloc;
  final Map<Player, Attendance> attendence = <Player, Attendance>{};

  void _openAttendance(BuildContext context, SingleGameBloc gameBloc) async {
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
        gameBloc.add(SingleGameUpdateAttendance(
            playerUid: player.uid, attendance: attend));
      }
    } else {
      Map<Player, Attendance> attend = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new MultipleAttendanceDialog(attendence);
          });
      if (attend != null) {
        attend.forEach((Player player, Attendance attend) {
          gameBloc.add(SingleGameUpdateAttendance(
              playerUid: player.uid, attendance: attend));
        });
      }
    }
  }

  void _editResult(BuildContext context, SingleGameBloc gameBloc) async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new EditResultDialog(gameBloc);
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

  Widget _buildAvailability(BuildContext context, SingleGameBloc gameBloc,
      Season season, List<Player> players) {
    Game game = gameBloc.state.game;
    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
    Team team = teamBloc.state.getTeam(game.teamUid);
    if (team == null) {
      return null;
    }
    if (season == null) {
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
    if (attendence.length == 0) {
      return null;
    }
    List<Widget> widgets = <Widget>[];
    attendence.forEach((Player player, Attendance attend) {
      widgets.add(new AttendanceIcon(attend));
    });
    return new GestureDetector(
      onTap: () {
        _openAttendance(context, gameBloc);
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

  Widget _buildInProgress(BuildContext context, Game game) {
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

  Widget _buildTrailing(BuildContext context, SingleGameBloc gameBloc,
      Season season, List<Player> players) {
    Game game = gameBloc.state.game;
    // Only show attendence until the game/event is over.
    if (game.result.inProgress == GameInProgress.NotStarted) {
      if ((game.trackAttendance &&
          game.sharedData.time >
              new DateTime.now()
                  .subtract(new Duration(hours: 2))
                  .millisecondsSinceEpoch)) {
        return _buildAvailability(context, gameBloc, season, players);
      }
    } else if (game.result.inProgress != GameInProgress.NotStarted) {
      return _buildInProgress(context, game);
    }
    return null;
  }

  void _showDirections(BuildContext context, Game game) {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(game.sharedData.place.address);
    if (game.sharedData.place.placeId != null) {
      url += "&destionation_place_id=" +
          Uri.encodeComponent(game.sharedData.place.placeId);
    }
    launch(url);
  }

  String _titleWidget(BuildContext context, Game game,
      LeagueOrTournamentTeam leagueTeam, SingleOpponentState opState) {
    String title;

    Opponent op = _opponentData(context, game, leagueTeam, opState);

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
    return title;
  }

  String _opponentUid(Game game) {
    if (game.sharedData.type == EventType.Game &&
        game.opponentUids.length > 0) {
      return game.opponentUids[0];
    }
    return "123";
  }

  Opponent _opponentData(BuildContext context, Game game,
      LeagueOrTournamentTeam leagueTeam, SingleOpponentState opState) {
    if (game.sharedData.type == EventType.Game &&
        game.opponentUids.length > 0) {
      return opState.opponent;
    } else if (game.sharedData.type == EventType.Game && leagueTeam != null) {
      return (OpponentBuilder()..name = leagueTeam.name).build();
    } else {
      return (OpponentBuilder()
            ..name = Messages.of(context).unknown
            ..teamUid = game.teamUid
            ..uid = "12")
          .build();
    }
  }

  Widget _buildMain(
      BuildContext context,
      SingleGameState gameState,
      SingleGameBloc gameBloc,
      LeagueOrTournamentTeam leagueTeam,
      SingleSeasonState seasonState) {
    Game game = gameState.game;
    List<Widget> buttons = <Widget>[];
    //print('Trying ${game.teamUid}');
    /*
    Opponent op;
    // Use the opponent from the main list before the league one if it is
    // set.
    if (game.sharedData.type == EventType.Game &&
        game.opponentUids.length > 0 &&
        team != null &&
        team.opponents.containsKey(game.opponentUids[0])) {
      op = team.opponents[game.opponentUids[0]];
    } else if (game.sharedData.type == EventType.Game && leagueTeam != null) {
      op = (OpponentBuilder()..name = leagueTeam.name).build();
    } else {
      op = (OpponentBuilder()
            ..name = Messages.of(context).unknown
            ..teamUid = game.teamUid
            ..uid = "12")
          .build();
    }
    */

    /*
    Season season;
    if (team != null) {
      season = team.seasons[game.seasonUid];
    }
    if (season == null) {
      season = new Season();
    }
    */

    TZDateTime timeNow = new TZDateTime.now(local);
    Duration dur = timeNow.difference(game.sharedData.tzTime).abs();

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
          onPressed: () => _showDirections(context, game),
          child: new Text(
            Messages.of(context).directionsbuttons,
          ),
        ),
      );
    }

    if (game.sharedData.time < new DateTime.now().millisecondsSinceEpoch &&
        game.sharedData.type == EventType.Game &&
        game.result.result == GameResult.Unknown) {
      if (game.sharedData.officialResult != null &&
          game.sharedData.officialResult.result != OfficialResult.InProgress &&
          game.sharedData.officialResult.result != OfficialResult.NotStarted) {
        buttons.add(new FlatButton(
          onPressed: () => _officalResult(context),
          child: new Text(Messages.of(context).useofficialresultbutton),
        ));
      }
      // Show a result button.
      buttons.add(
        new FlatButton(
          onPressed: () => _editResult(context, gameBloc),
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
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);

    players = playerBloc.state.players.values
        .where((Player p) => seasonState.season.players
            .any((SeasonPlayer sp) => sp.playerUid == p.uid))
        .toList();

    Color color = Colors.white;

    if (game.sharedData.time < timeNow.millisecondsSinceEpoch &&
        dur.inMinutes < 60) {
      color = Colors.lightBlueAccent;
    }

    ListTile tile = new ListTile(
      onTap: () {
        Navigator.pushNamed(context, "/Game/" + game.uid);
      },
      leading: new TeamImage(
        teamUid: game.teamUid,
        width: 50.0,
        height: 50.0,
      ),
      title: SingleOpponentProvider(
        opponentUid: _opponentUid(game),
        builder: (BuildContext context, SingleOpponentBloc opBloc) =>
            BlocBuilder(
          cubit: opBloc,
          builder: (BuildContext context, SingleOpponentState opState) => Text(
            _titleWidget(context, game, leagueTeam, opState),
            overflow: TextOverflow.clip,
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      subtitle: SingleTeamProvider(
        teamUid: game.teamUid,
        builder: (BuildContext context, SingleTeamBloc teamBloc) => BlocBuilder(
            cubit: teamBloc,
            builder: (BuildContext context, SingleTeamState state) {
              for (Player play in players) {
                subtitle.add(
                  TextSpan(
                    style: Theme.of(context).textTheme.subhead,
                    text: Messages.of(context).nameandteam(state.team, play),
                  ),
                );
              }

              return RichText(
                text: new TextSpan(
                  style: Theme.of(context).textTheme.subhead,
                  children: subtitle,
                ),
              );
            }),
      ),
      trailing: _buildTrailing(context, gameBloc, seasonState.season, players),
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

  Widget _buildFromnState(BuildContext context, SingleGameBloc gameBloc) {
    return BlocBuilder(
      cubit: gameBloc,
      builder: (BuildContext context, SingleGameState state) {
        if (state is SingleGameDeleted) {
          return SizedBox();
        }
        print("Building game ${state.game.uid}");
        Game game = state.game;
        if (game.leagueOpponentUid != null &&
            game.leagueOpponentUid.isNotEmpty) {
          // Show this in a future.
          return SingleLeagueOrTournamentTeamProvider(
            leagueTeamUid: game.leagueOpponentUid,
            builder: (BuildContext context,
                    SingleLeagueOrTournamentTeamBloc leagueTeamBloc) =>
                BlocBuilder(
              cubit: leagueTeamBloc,
              builder: (BuildContext context,
                      SingleLeagueOrTournamentTeamState teamState) =>
                  SingleSeasonProvider(
                seasonUid: game.seasonUid,
                builder: (BuildContext contrext, SingleSeasonBloc seasonBloc) =>
                    BlocBuilder(
                  cubit: seasonBloc,
                  builder:
                      (BuildContext context, SingleSeasonState seasonState) {
                    return _buildMain(context, state, gameBloc,
                        teamState.leagueOrTournamentTeam, seasonState);
                  },
                ),
              ),
            ),
          );
        }
        return SingleSeasonProvider(
          seasonUid: game.seasonUid,
          builder: (BuildContext contrext, SingleSeasonBloc seasonBloc) =>
              BlocBuilder(
            cubit: seasonBloc,
            builder: (BuildContext context, SingleSeasonState seasonState) =>
                _buildMain(context, state, gameBloc, null, seasonState),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (singleGameBloc != null) {
      return _buildFromnState(context, singleGameBloc);
    }
    return SingleGameProvider(
      gameUid: gameUid,
      builder: (BuildContext context, SingleGameBloc gameBloc) =>
          _buildFromnState(context, gameBloc),
    );
  }
}
