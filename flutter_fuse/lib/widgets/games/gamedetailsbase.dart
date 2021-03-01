import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timezone/timezone.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import '../games/attendanceicon.dart';
import '../teams/teamimage.dart';
import 'basketball/gameduration.dart';
import 'basketball/gamesummary.dart';
import 'gamemapview.dart';
import 'teamresults.dart';

/// Callback for the game.
typedef GameCallback = void Function(Game game);

/// Callback for the offical result.
typedef GameOfficialResult = void Function(
    GameSharedData sharedData, GameResultSharedDetails details);

/// Callback for the result of copying a game.
typedef GameCopyResult = void Function(
    GameSharedData sharedData, GameFromOfficial details);

/// Callback when the attendance thing is being opened.
typedef GameOpenAttendence = void Function(
    Game game, Map<Player, Attendance> attendence);

///
/// The base for the game details.
///
class GameDetailsBase extends StatelessWidget {
  /// Constructor.
  GameDetailsBase(
      {this.game,
      this.adding,
      this.editResult,
      this.openAttendence,
      this.openNavigation,
      this.editOfficialResult,
      this.copyOfficalResult});

  /// The game.
  final Game game;

  /// If we are currently adding this game
  final bool adding;

  /// The edit callback for when it is edited.
  final GameCallback editResult;

  /// Callback to open the attendence pieces
  final GameOpenAttendence openAttendence;

  /// Navigate to the specific game.
  final GameCallback openNavigation;

  /// The callback to edit the offical results.
  final GameOfficialResult editOfficialResult;

  /// The callback when the offical result is copied to the local result.
  final GameCopyResult copyOfficalResult;

  Widget _buildAttendence(Game game, Season season, PlayerState playerState) {
    var availability = <Widget>[];
    var availavilityResult = <Player, Attendance>{};

    if (season != null) {
      playerState.players.forEach((key, player) {
        if (season.players.any((play) {
          return play.playerUid == key;
        })) {
          var attend = Attendance.Maybe;
          if (game.attendance.containsKey(key)) {
            attend = game.attendance[key];
          }
          availavilityResult[player] = attend;
          availability.add(
            Row(
              children: <Widget>[
                Expanded(child: Text(player.name)),
                AttendanceIcon(attend),
              ],
            ),
          );
        }
      });
    }

    // Not started, show availability.
    return ListTile(
      leading: const Icon(MdiIcons.bookOpenVariant),
      title: GestureDetector(
        onTap: () => openAttendence != null
            ? openAttendence(game, availavilityResult)
            : null,
        child: Column(
          children: availability,
        ),
      ),
    );
  }

  void _tapListTile(bool official, GameSharedData sharedData,
      GameResultSharedDetails details) {
    if (official) {
      if (editOfficialResult != null) {
        editOfficialResult(sharedData, details);
      }
    } else {
      if (editResult != null) {
        editResult(game);
      }
    }
  }

  Widget _buildGameResult(
      BuildContext context,
      bool official,
      GameSharedData sharedData,
      GameResultSharedDetails details,
      bool inProgress,
      bool dontMatch) {
    // Started.
    TextSpan title;
    var theme = Theme.of(context);
    switch (details.result) {
      case GameResult.Unknown:
        if (inProgress) {
          title = TextSpan(
              text: Messages.of(context).resultInProgress(details),
              style: theme.textTheme.subtitle1);
        } else {
          title = TextSpan(
              text: Messages.of(context).noResult,
              style: theme.textTheme.subtitle1);
        }
        break;
      case GameResult.Loss:
        title = TextSpan(
            text: Messages.of(context).resultLoss(details),
            style: theme.textTheme.subtitle1.copyWith(color: theme.errorColor));
        break;
      case GameResult.Win:
        title = TextSpan(
            text: Messages.of(context).resultWin(details),
            style:
                theme.textTheme.subtitle1.copyWith(color: theme.accentColor));
        break;
      case GameResult.Tie:
        title = TextSpan(
            text: Messages.of(context).resultTie(details),
            style: theme.textTheme.subtitle1);
        break;
    }

    if (official) {
      title = TextSpan(
          text: "${Messages.of(context).offical}\n",
          style:
              theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600),
          children: <TextSpan>[title]);
    }

    return ListTile(
      onTap: () => _tapListTile(official, sharedData, details),
      leading: official
          ? (dontMatch
              ? Icon(Icons.error, color: theme.errorColor)
              : Icon(MdiIcons.bookOpen))
          : Icon(MdiIcons.bookOpenVariant),
      title: RichText(text: title),
      subtitle: dontMatch
          ? Text(
              Messages.of(context).officialdontmatch,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: theme.errorColor),
            )
          : inProgress
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Messages.of(context)
                          .getPeriodName(game.result.currentPeriod),
                      style: Theme.of(context).textTheme.bodyText2,
                      textScaleFactor: 1.5,
                    ),
                    GameDuration(
                      game: game,
                      style: Theme.of(context).textTheme.bodyText2,
                      textScaleFactor: 1.5,
                    ),
                  ],
                )
              : null,
    );
  }

  Widget _buildGame(BuildContext context, SingleTeamState teamState) {
    var day = TimeOfDay.fromDateTime(game.sharedData.tzTime);
    var dayArrive = TimeOfDay.fromDateTime(game.tzArriveTime);
    var dayEnd = TimeOfDay.fromDateTime(game.sharedData.tzEndTime);
    var dateStr = MaterialLocalizations.of(context)
        .formatFullDate(game.sharedData.tzTime);
    var timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    var endTimeStr = MaterialLocalizations.of(context).formatTimeOfDay(dayEnd);
    String tzShortName;
    if (game.sharedData.timezone != local.name) {
      var abbr = getLocation(game.sharedData.timezone)
          .timeZone(game.sharedData.time.millisecondsSinceEpoch)
          .abbr;

      tzShortName = " ($abbr)";
    }
    String arriveAttimeStr;
    if (dayArrive.minute == day.minute && dayArrive.hour == day.hour) {
      arriveAttimeStr =
          MaterialLocalizations.of(context).formatTimeOfDay(dayArrive) +
              (tzShortName ?? "");
    } else {
      arriveAttimeStr = MaterialLocalizations.of(context).formatTimeOfDay(day) +
          (tzShortName ?? "");
    }
    var opponent = teamState.opponents[game.opponentUid];
    var season = teamState.getSeason(game.seasonUid);

    var theme = Theme.of(context);

    var top = <Widget>[];
    // Map view.
    top.add(
      Container(
        height: 250.0,
        child: Stack(
          children: <Widget>[
            Center(
              child: GameMapView(game.sharedData),
            ),
            Positioned(
              right: 20.0,
              bottom: 0.0,
              child: FloatingActionButton(
                onPressed: () =>
                    openNavigation != null ? openNavigation(game) : null,
                child: const Icon(Icons.directions),
                backgroundColor: Colors.orange,
                heroTag: game.uid,
              ),
            ),
          ],
        ),
      ),
    );

    // Team details
    top.add(
      ListTile(
        leading: TeamImage(
          team: teamState.team,
          width: 50.0,
          height: 50.0,
        ),
        title: Text(teamState.team.name, style: theme.textTheme.headline6),
        subtitle:
            arriveAttimeStr != null && game.sharedData.type == EventType.Game
                ? Text('arrive at $arriveAttimeStr',
                    style: theme.textTheme.subtitle1)
                : null,
        trailing: game.homegame ? const Icon(Icons.home) : null,
      ),
    );

    // Map details
    var timeEnd = (game.sharedData.endTime == game.sharedData.time
        ? ''
        : " - $endTimeStr ${tzShortName ?? ''}");
    var body = <Widget>[];
    body.add(
      ListTile(
        leading: Icon(Icons.directions),
        title: Text(
          "$dateStr $timeStr$timeEnd",
          style: theme.textTheme.subtitle1.copyWith(color: theme.accentColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(game.sharedData.place.name ?? ''),
            Text(game.sharedData.place.address ?? Messages.of(context).unknown),
          ],
        ),
      ),
    );

    // Results.
    if (game.sharedData.type == EventType.Game) {
      if (adding) {
        body.add(
          ListTile(
            leading: Icon(MdiIcons.bookOpenVariant),
            title: Text(Messages.of(context).gametype),
          ),
        );
      } else {
        if (game.result.inProgress == GameInProgress.NotStarted) {
          if (game.trackAttendance) {
            body.add(
              BlocBuilder(
                  cubit: BlocProvider.of<PlayerBloc>(context),
                  builder: (context, playerState) =>
                      _buildAttendence(game, season, playerState)),
            );
          }
        }
        // Show the live stuff if the game is close to starting.
        body.add(_buildGameResult(context, false, game.sharedData, game.result,
            game.result.inProgress == GameInProgress.InProgress, false));
        if (game.sharedData.time
                .isAfter(clock.now().subtract(const Duration(hours: 1))) &&
            !game.result.isGameFinished) {
          if (editResult != null) {
            body.add(ButtonBar(
              children: <Widget>[
                TextButton(
                  child: Text(Messages.of(context).addResultButton),
                  onPressed: () => editResult(game),
                ),
              ],
            ));
          }
        }

        // Official results.
        var officalData =
            GameFromOfficial(game.sharedData, game.leagueOpponentUid);
        // Only show official links for games in a league/tournament.
        if (game.sharedData.leagueUid != null &&
            game.sharedData.leagueUid.isNotEmpty) {
          body.add(_buildGameResult(
              context,
              true,
              game.sharedData,
              officalData,
              game.sharedData.officialResult.result ==
                  OfficialResult.InProgress,
              officalData.isSameAs(game.result)));
          if (!officalData.isSameAs(game.result)) {
            if (copyOfficalResult != null) {
              body.add(ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text(Messages.of(context).useofficialresultbutton),
                    onPressed: () =>
                        copyOfficalResult(game.sharedData, officalData),
                  ),
                ],
              ));
            }
          }
        }
      }
    } else {
      // Tell people this is a practice or special event.
      if (game.sharedData.type == EventType.Practice) {
        body.add(
          ListTile(
            leading: const Icon(Icons.train),
            title: Text(Messages.of(context).trainingtype),
          ),
        );
      } else if (game.sharedData.type == EventType.Event) {
        body.add(
          ListTile(
            leading: const Icon(Icons.plus_one),
            title: Text(Messages.of(context).eventtype),
          ),
        );
      }
      // Attendance, possibly.
      if (!adding &&
          game.trackAttendance &&
          game.sharedData.time
              .isAfter(clock.now().subtract(const Duration(hours: 1)))) {
        body.add(
          BlocBuilder(
            cubit: BlocProvider.of<PlayerBloc>(context),
            builder: (context, playerState) =>
                _buildAttendence(game, season, playerState),
          ),
        );
      }
    }

    // Uniform
    if (game.uniform != null && game.uniform.isNotEmpty) {
      body.add(
        ListTile(
          leading: const Icon(MdiIcons.tshirtCrew),
          title: Text(game.uniform == null ? 'fluff' : game.uniform),
        ),
      );
    }

    // Notes.
    if (game.notes != null && game.notes.isNotEmpty) {
      body.add(
        ListTile(
          leading: const Icon(Icons.note),
          title: Text(game.notes),
        ),
      );
    }

    // Opponent last games.
    if (game.sharedData.type == EventType.Game && !adding) {
      String seasonName;
      if (season != null) {
        seasonName = season.name;
      } else {
        seasonName = Messages.of(context).unknown;
      }
      body.add(
        ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                opponent != null
                    ? Messages.of(context)
                        .opponentSeason(opponent.name, seasonName)
                    : Messages.of(context).loading,
              ),
              Text(
                opponent != null
                    ? Messages.of(context)
                        .opponentwinrecord(opponent, game.seasonUid, seasonName)
                    : Messages.of(context).loading,
              ),
            ],
          ),
          initiallyExpanded: false,
          leading: const Icon(Icons.people),
          children: <Widget>[
            TeamResultsBySeason(
              teamUid: teamState.team.uid,
              seasonUid: game.seasonUid,
              opponentUid: game.opponentUid,
            ),
          ],
        ),
      );
      if (teamState.fullSeason.length > 1) {
        var cols = <Widget>[];
        for (var otherSeason in teamState.fullSeason) {
          if (otherSeason.uid != season.uid) {
            String seasonName;
            seasonName = otherSeason.name;

            cols.add(
              Text(
                opponent != null
                    ? Messages.of(context)
                        .opponentSeason(opponent.name, seasonName)
                    : Messages.of(context).loading,
              ),
            );
            cols.add(
              Text(
                opponent != null
                    ? Messages.of(context).opponentwinrecord(
                        opponent, otherSeason.uid, seasonName)
                    : Messages.of(context).loading,
              ),
            );
            cols.add(
              TeamResultsBySeason(
                teamUid: teamState.team.uid,
                seasonUid: otherSeason.uid,
                opponentUid: game.opponentUid,
              ),
            );
          }
        }
        body.add(
          ExpansionTile(
            title: Text(Messages.of(context).previousSeasons),
            initiallyExpanded: false,
            leading: const Icon(Icons.people),
            children: cols,
          ),
        );
      }
      if (teamState.team?.sport == Sport.Basketball &&
          game.result.inProgress != GameInProgress.NotStarted) {
        body.add(
          Padding(
            padding: EdgeInsets.all(10),
            child: BasketballGameSummary(game),
          ),
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ...top,
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: body,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: game.teamUid,
      builder: (context, bloc) => BlocListener(
        cubit: bloc,
        listener: (context, state) {
          if (state is SingleTeamLoaded) {
            bloc.add(SingleTeamLoadOpponents());
          }
        },
        child: BlocBuilder(
            cubit: bloc,
            builder: (context, teamState) {
              if (!teamState.loadedOpponents) {
                bloc.add(SingleTeamLoadOpponents());
              }
              if (!teamState.loadedSeasons) {
                bloc.add(SingleTeamLoadSeasons());
              }
              return _buildGame(context, teamState);
            }),
      ),
    );
  }
}
