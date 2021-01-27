import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/messages.dart';
import '../blocs/singlegameprovider.dart';
import '../blocs/singleleagueortournamentteamprovider.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../games/attendancedialog.dart';
import '../games/editresultdialog.dart';
import '../games/multipleattendencedialog.dart';
import '../teams/teamimage.dart';
import 'attendanceicon.dart';
import 'gametitle.dart';

///
/// Shows the game as a card to display in various lists.
///
class GameCard extends StatelessWidget {
  /// Constructor.
  GameCard({@required this.gameUid, this.singleGameBloc})
      : assert(gameUid != null || singleGameBloc != null);

  /// The gameUid for the game.
  final String gameUid;

  /// The single game block to use
  final SingleGameBloc singleGameBloc;

  /// current attendence details for the game.
  final Map<Player, Attendance> attendence = <Player, Attendance>{};

  void _openAttendance(BuildContext context, SingleGameBloc gameBloc) async {
    if (attendence.length == 1) {
      // Do a simple picker popup.
      var player = attendence.keys.first;
      var current = attendence[player];

      var attend = await showDialog<Attendance>(
          context: context,
          builder: (context) {
            return AttendanceDialog(current: current);
          });
      if (attend != null) {
        gameBloc.add(SingleGameUpdateAttendance(
            playerUid: player.uid, attendance: attend));
      }
    } else {
      var attend = await showDialog<Map<Player, Attendance>>(
          context: context,
          builder: (context) {
            return MultipleAttendanceDialog(attendence);
          });
      if (attend != null) {
        for (var a in attend.entries) {
          gameBloc.add(SingleGameUpdateAttendance(
              playerUid: a.key.uid, attendance: a.value));
        }
      }
    }
  }

  void _editResult(BuildContext context, SingleGameBloc gameBloc) async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditResultDialog(gameBloc);
      },
    );
  }

  void _officalResult(BuildContext context) async {
    // Call up a dialog to edit the result.
    /*
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return EditResultDialog(game);
      },
    );
    */
  }

  Widget _buildAvailability(BuildContext context, SingleGameBloc gameBloc,
      Season season, List<Player> players) {
    var game = gameBloc.state.game;
    var teamBloc = BlocProvider.of<TeamBloc>(context);
    var team = teamBloc.state.getTeam(game.teamUid);
    if (team == null) {
      return null;
    }
    if (season == null) {
      return null;
    }

    // Show current availability.
    for (var player in players) {
      if (game.attendance.containsKey(player.uid)) {
        attendence[player] = game.attendance[player.uid];
      } else {
        attendence[player] = Attendance.Maybe;
      }
    }
    if (attendence.length == 0) {
      return null;
    }
    var widgets = <Widget>[];
    attendence.forEach((player, attend) {
      widgets.add(AttendanceIcon(attend));
    });
    return GestureDetector(
      onTap: () {
        _openAttendance(context, gameBloc);
      },
      child: Column(children: widgets),
    );
  }

  List<Widget> _buildResultColumn(
      BuildContext context,
      GameResultPerPeriod finalResult,
      GameResultPerPeriod overtimeResult,
      GameResultPerPeriod penaltyResult,
      GameResult result) {
    var style = Theme.of(context).textTheme.bodyText2;
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
    var children = <Widget>[];
    children.add(
      Text(
        Messages.of(context).gameresult(result),
        style: style,
      ),
    );
    children.add(
      Text(
        "${finalResult.score.ptsFor} - ${finalResult.score.ptsAgainst}",
        style: style,
      ),
    );
    if (overtimeResult != null) {
      children.add(
        Text(
          "OT ${overtimeResult.score.ptsFor} - ${overtimeResult.score.ptsAgainst}",
          style: style,
        ),
      );
    }
    if (penaltyResult != null) {
      children.add(
        Text(
          "PT ${penaltyResult.score.ptsFor} - ${penaltyResult.score.ptsAgainst}",
          style: style,
        ),
      );
    }
    return children;
  }

  Widget _buildInProgress(BuildContext context, Game game) {
    var officalData = GameFromOfficial(game.sharedData, game.leagueOpponentUid);
    if (game.result.inProgress == GameInProgress.Final) {
      GameResultPerPeriod finalResult;
      GameResultPerPeriod overtimeResult;
      GameResultPerPeriod penaltyResult;
      for (var result in game.result.scores.values) {
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
          case GamePeriodType.Final:
            finalResult = result;
            break;
          default:
            break;
        }
      }

      if (game.result.result != GameResult.Unknown) {
        GameResultPerPeriod emptyPeriodResult = GameResultPerPeriod((q) => q
          ..period = GamePeriod.finalPeriod.toBuilder()
          ..score.ptsFor = 0
          ..score.ptsAgainst = 0);
        var children = _buildResultColumn(
            context,
            finalResult ?? emptyPeriodResult,
            overtimeResult,
            penaltyResult,
            game.result.result);
        // If there is an offical result and it is different, mark this.
        if (officalData.isGameFinished) {
          if (!officalData.isSameAs(game.result)) {
            children
                .add(Icon(Icons.error, color: Theme.of(context).errorColor));
          }
        }
        return Column(
          children: children,
        );
      }
    } else {
      // See if there is an offical result.
      if (officalData.isGameFinished) {
        var children = _buildResultColumn(
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
    return Column(
      children: <Widget>[
        Text(
          Messages.of(context).gameinprogress(game.result.inProgress),
        ),
        Text(
          Messages.of(context).cardresultinprogress(game.result),
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context, SingleGameBloc gameBloc,
      Season season, List<Player> players) {
    var game = gameBloc.state.game;
    // Only show attendence until the game/event is over.
    if (game.result.inProgress == GameInProgress.NotStarted) {
      if ((game.trackAttendance &&
          game.sharedData.time
              .isAfter(DateTime.now().subtract(Duration(hours: 2))))) {
        return _buildAvailability(context, gameBloc, season, players);
      }
    } else if (game.result.inProgress != GameInProgress.NotStarted) {
      return _buildInProgress(context, game);
    }
    return null;
  }

  void _showDirections(BuildContext context, Game game) {
    var url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=${Uri.encodeComponent(game.sharedData.place.address)}";
    if (game.sharedData.place.placeId != null) {
      url +=
          "&destionation_place_id=${Uri.encodeComponent(game.sharedData.place.placeId)}";
    }
    launch(url);
  }

  Widget _buildMain(
      BuildContext context,
      SingleGameState gameState,
      SingleGameBloc gameBloc,
      LeagueOrTournamentTeam leagueTeam,
      SingleSeasonState seasonState) {
    var game = gameState.game;
    var buttons = <Widget>[];
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
      season = Season();
    }
    */

    var timeNow = TZDateTime.now(local);
    var dur = timeNow.difference(game.sharedData.tzTime).abs();

    String arriveFormat;
    // Only arrival time for games and only if it is before the game.
    if (game.arrivalTime != game.sharedData.time &&
        game.sharedData.type == EventType.Game &&
        timeNow.isBefore(game.arrivalTime
            .add(Duration(milliseconds: Duration.millisecondsPerHour)))) {
      var arriveDay = TimeOfDay.fromDateTime(game.tzArriveTime);
      arriveFormat =
          MaterialLocalizations.of(context).formatTimeOfDay(arriveDay);
    }

    if (game.arrivalTime.isBefore(timeNow
            .subtract(Duration(milliseconds: Duration.millisecondsPerHour))) &&
        game.arrivalTime.isAfter(timeNow
            .add(Duration(milliseconds: Duration.millisecondsPerHour * 3)))) {
      // Put in directions buttons.
      buttons.add(
        FlatButton(
          onPressed: () => _showDirections(context, game),
          child: Text(
            Messages.of(context).directionsbuttons,
          ),
        ),
      );
    }

    if (game.sharedData.time.isBefore(DateTime.now()) &&
        game.sharedData.type == EventType.Game &&
        game.result.result == GameResult.Unknown) {
      if (game.sharedData.officialResult != null &&
          game.sharedData.officialResult.result != OfficialResult.InProgress &&
          game.sharedData.officialResult.result != OfficialResult.NotStarted) {
        buttons.add(FlatButton(
          onPressed: () => _officalResult(context),
          child: Text(Messages.of(context).useofficialresultbutton),
        ));
      }
      // Show a result button.
      buttons.add(
        FlatButton(
          onPressed: () => _editResult(context, gameBloc),
          child: Text(Messages.of(context).addresultbutton),
        ),
      );
    }

    var subtitle = <TextSpan>[];
    if (arriveFormat != null) {
      var addr = game.sharedData.place.address;
      if (game.sharedData.place.name.isNotEmpty) {
        addr = game.sharedData.place.name;
      }
      subtitle.add(
        TextSpan(
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(fontWeight: FontWeight.bold),
          text:
              "${Messages.of(context).gameaddressarriveat(arriveFormat, addr)}\n",
        ),
      );
    } else {
      if (game.sharedData.place.name.isNotEmpty) {
        subtitle.add(
          TextSpan(
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold),
            text: "${game.sharedData.place.name}\n",
          ),
        );
      } else {
        subtitle.add(
          TextSpan(
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold),
            text: "${game.sharedData.place.address}\n",
          ),
        );
      }
    }
    var players = <Player>[];
    var playerBloc = BlocProvider.of<PlayerBloc>(context);

    players = playerBloc.state.players.values
        .where((p) =>
            seasonState.season.players.any((sp) => sp.playerUid == p.uid))
        .toList();

    var color = Colors.white;

    if (game.sharedData.time.isBefore(timeNow) && dur.inMinutes < 60) {
      color = Colors.lightBlueAccent;
    }

    var tile = ListTile(
      onTap: () {
        Navigator.pushNamed(context, "/Game/${game.uid}");
      },
      leading: TeamImage(
        teamUid: game.teamUid,
        width: 50.0,
        height: 50.0,
      ),
      title: GameTitle(game, leagueTeam),
      subtitle: SingleTeamProvider(
        teamUid: game.teamUid,
        builder: (context, teamBloc) => BlocBuilder(
            cubit: teamBloc,
            builder: (context, state) {
              for (var play in players) {
                subtitle.add(
                  TextSpan(
                    style: Theme.of(context).textTheme.subtitle1,
                    text: Messages.of(context).nameandteam(state.team, play),
                  ),
                );
              }

              return RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.subtitle1,
                  children: subtitle,
                ),
              );
            }),
      ),
      trailing: _buildTrailing(context, gameBloc, seasonState.season, players),
    );
    if (buttons.length > 0) {
      return Card(
        color: color,
        child: Column(
          children: <Widget>[
            tile,

            // make buttons use the appropriate styles for cards
            ButtonBar(
              children: buttons,
            ),
          ],
        ),
      );
    } else {
      return Card(
        color: color,
        child: tile,
      );
    }
  }

  Widget _buildFromnState(BuildContext context, SingleGameBloc gameBloc) {
    return BlocBuilder(
      cubit: gameBloc,
      builder: (context, state) {
        if (state is SingleGameDeleted) {
          return SizedBox();
        }
        if (state is SingleGameUninitialized) {
          return Card(
            color: Colors.lightGreenAccent,
            child: Text(Messages.of(context).loading),
          );
        }
        Game game = state.game;
        if (game.leagueOpponentUid != null &&
            game.leagueOpponentUid.isNotEmpty) {
          // Show this in a future.
          return SingleLeagueOrTournamentTeamProvider(
            leagueTeamUid: game.leagueOpponentUid,
            builder: (context, leagueTeamBloc) => BlocBuilder(
              cubit: leagueTeamBloc,
              builder: (context, teamState) => SingleSeasonProvider(
                seasonUid: game.seasonUid,
                builder: (contrext, seasonBloc) => BlocBuilder(
                  cubit: seasonBloc,
                  builder: (context, seasonState) {
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
          builder: (contrext, seasonBloc) => BlocBuilder(
            cubit: seasonBloc,
            builder: (context, seasonState) =>
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
      builder: _buildFromnState,
    );
  }
}
