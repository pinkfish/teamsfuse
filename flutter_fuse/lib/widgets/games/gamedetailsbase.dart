import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

/// Callback for the official result.
typedef GameOfficialResult = void Function(
    GameSharedData sharedData, GameResultSharedDetails details);

/// Callback for the result of copying a game.
typedef GameCopyResult = void Function(
    GameSharedData sharedData, GameFromOfficial details);

/// Callback when the attendance thing is being opened.
typedef GameOpenAttendance = void Function(
    Game game, Map<Player, Attendance> attendance);

///
/// The base for the game details.
///
class GameDetailsBase extends StatelessWidget {
  /// Constructor.
  GameDetailsBase(
      {@required this.game,
      this.gameMedia,
      this.adding,
      this.editResult,
      this.openAttendance,
      this.openNavigation,
      this.openAddMedia,
      this.editOfficialResult,
      this.copyOfficialResult});

  /// The game.
  final Game game;

  /// Media for the game
  final BuiltList<MediaInfo> gameMedia;

  /// If we are currently adding this game
  final bool adding;

  /// The edit callback for when it is edited.
  final GameCallback editResult;

  /// Callback to open the attendance pieces
  final GameOpenAttendance openAttendance;

  /// Navigate to the specific game.
  final GameCallback openNavigation;

  /// Navigate to the specific game.
  final GameCallback openAddMedia;

  /// The callback to edit the official results.
  final GameOfficialResult editOfficialResult;

  /// The callback when the official result is copied to the local result.
  final GameCopyResult copyOfficialResult;

  Widget _buildAttendance(Game game, Season season, PlayerState playerState) {
    var availability = <Widget>[];
    var availabilityResult = <Player, Attendance>{};

    if (season != null) {
      playerState.players.forEach((key, player) {
        if (season.players.any((play) {
          return play.playerUid == key;
        })) {
          var attend = Attendance.Maybe;
          if (game.attendance.containsKey(key)) {
            attend = game.attendance[key];
          }
          availabilityResult[player] = attend;
          availability.add(
            Row(
              children: <Widget>[
                Expanded(child: Text(player.name)),
                Ink(
                  decoration: ShapeDecoration(
                    color: Colors.lightBlue.shade50,
                    shape: CircleBorder(),
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: AttendanceIcon(
                      attend,
                    ),
                  ),
                ),
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
        onTap: () => openAttendance != null
            ? openAttendance(game, availabilityResult)
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
      bool doNotMatch) {
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
          text: '${Messages.of(context).official}\n',
          style:
              theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.w600),
          children: <TextSpan>[title]);
    }

    return ListTile(
      onTap: () => _tapListTile(official, sharedData, details),
      leading: official
          ? (doNotMatch
              ? Icon(Icons.error, color: theme.errorColor)
              : Icon(MdiIcons.bookOpen))
          : Icon(MdiIcons.bookOpenVariant),
      title: RichText(text: title),
      subtitle: doNotMatch
          ? Text(
              Messages.of(context).officialDoNotMatch,
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
          .abbreviation;

      tzShortName = ' ($abbr)';
    }
    String arriveAtTimeStr;
    if (dayArrive.minute == day.minute && dayArrive.hour == day.hour) {
      arriveAtTimeStr =
          MaterialLocalizations.of(context).formatTimeOfDay(dayArrive) +
              (tzShortName ?? '');
    } else {
      arriveAtTimeStr = MaterialLocalizations.of(context).formatTimeOfDay(day) +
          (tzShortName ?? '');
    }
    var opponent = teamState.opponents[game.opponentUid];
    var season = teamState.getSeason(game.seasonUid);

    var theme = Theme.of(context);

    var top = <Widget>[];
    // Map view.
    top.add(
      Container(
        height: 250.0,
        child: Center(
          child: GameMapView(game.sharedData),
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
            arriveAtTimeStr != null && game.sharedData.type == EventType.Game
                ? Text('arrive at $arriveAtTimeStr',
                    style: theme.textTheme.subtitle1)
                : null,
        trailing: game.homeGame ? const Icon(Icons.home) : null,
      ),
    );

    // Map details
    var timeEnd = (game.sharedData.endTime == game.sharedData.time
        ? ''
        : ' - $endTimeStr ${tzShortName ?? ''}');
    var body = <Widget>[];
    body.add(
      Stack(
        children: [
          ListTile(
            leading: Icon(Icons.directions),
            title: Text(
              '$dateStr $timeStr$timeEnd',
              style:
                  theme.textTheme.subtitle1.copyWith(color: theme.accentColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(game.sharedData.place.name ?? ''),
                Text(game.sharedData.place.address ??
                    Messages.of(context).unknown),
              ],
            ),
          ),
          Positioned(
            right: 5.0,
            top: 5.0,
            child: FloatingActionButton(
              onPressed: () =>
                  openNavigation != null ? openNavigation(game) : null,
              backgroundColor: Colors.orange,
              heroTag: game.uid,
              child: const Icon(Icons.directions),
            ),
          ),
        ],
      ),
    );

    // Results.
    if (game.sharedData.type == EventType.Game) {
      if (adding) {
        body.add(
          ListTile(
            leading: Icon(MdiIcons.bookOpenVariant),
            title: Text(Messages.of(context).gameType),
          ),
        );
      } else {
        if (game.result.inProgress == GameInProgress.NotStarted) {
          if (game.trackAttendance) {
            body.add(
              BlocBuilder(
                  bloc: BlocProvider.of<PlayerBloc>(context),
                  builder: (context, playerState) =>
                      _buildAttendance(game, season, playerState)),
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
                  onPressed: () => editResult(game),
                  child: Text(Messages.of(context).addResultButton),
                ),
              ],
            ));
          }
        }

        // Official results.
        var officialData =
            GameFromOfficial(game.sharedData, game.leagueOpponentUid);
        // Only show official links for games in a league/tournament.
        if (game.sharedData.leagueUid != null &&
            game.sharedData.leagueUid.isNotEmpty) {
          body.add(_buildGameResult(
              context,
              true,
              game.sharedData,
              officialData,
              game.sharedData.officialResult.result ==
                  OfficialResult.InProgress,
              officialData.isSameAs(game.result)));
          if (!officialData.isSameAs(game.result)) {
            if (copyOfficialResult != null) {
              body.add(ButtonBar(
                children: <Widget>[
                  TextButton(
                    onPressed: () =>
                        copyOfficialResult(game.sharedData, officialData),
                    child: Text(Messages.of(context).useOfficialResultButton),
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
            title: Text(Messages.of(context).trainingType),
          ),
        );
      } else if (game.sharedData.type == EventType.Event) {
        body.add(
          ListTile(
            leading: const Icon(Icons.plus_one),
            title: Text(Messages.of(context).eventType),
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
            bloc: BlocProvider.of<PlayerBloc>(context),
            builder: (context, playerState) =>
                _buildAttendance(game, season, playerState),
          ),
        );
      }
    }

    // Uniform
    if (game.uniform != null && game.uniform.isNotEmpty) {
      body.add(
        ListTile(
          leading: const Icon(MdiIcons.tshirtCrew),
          title: Text(game.uniform ?? 'fluff'),
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

    // Media
    if (gameMedia != null) {
      body.add(
        ListTile(
          leading: Icon(Icons.image),
          title: gameMedia.isEmpty
              ? Text(Messages.of(context).noMedia)
              : SizedBox(
                  height: 90,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, '/Game/Media/View/${game.uid}'),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: gameMedia
                          .map<Widget>(
                            (MediaInfo info) => Container(
                              height: 80,
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: info.url.toString(),
                                  height: 80,
                                  errorWidget: (c, str, e) => Icon(Icons.error),
                                  placeholder: (c, str) =>
                                      CircularProgressIndicator(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
        ),
      );
      body.add(ButtonBar(
        children: [
          TextButton(
            onPressed: () => openAddMedia(game),
            child: Text(Messages.of(context).addMediaButton),
          ),
        ],
      ));
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
            mainAxisSize: MainAxisSize.min,
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
                        .opponentWinRecord(opponent, game.seasonUid, seasonName)
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
                    ? Messages.of(context).opponentWinRecord(
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

    return LayoutBuilder(
      builder: (context, c) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...top,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: body,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: game.teamUid,
      builder: (context, bloc) => BlocListener(
        bloc: bloc,
        listener: (context, state) {
          if (state is SingleTeamLoaded) {
            bloc.add(SingleTeamLoadOpponents());
          }
        },
        child: BlocBuilder(
            bloc: bloc,
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
