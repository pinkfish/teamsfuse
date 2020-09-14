import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/map_view/marker.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/attendanceicon.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../blocs/singleteamprovider.dart';
import 'teamresults.dart';

typedef void GameCallback(Game game);
typedef void GameOfficialResult(
    GameSharedData sharedData, GameResultSharedDetails details);
typedef void GameCopyResult(
    GameSharedData sharedData, GameFromOfficial details);
typedef void GameOpenAttendence(Game game, Map<Player, Attendance> attendence);

class GameDetailsBase extends StatelessWidget {
  GameDetailsBase(
      {this.game,
      this.adding,
      this.editResult,
      this.openAttendence,
      this.openNavigation,
      this.editOfficialResult,
      this.copyOfficalResult});

  final Game game;
  final bool adding;
  final GameCallback editResult;
  final GameOpenAttendence openAttendence;
  final GameCallback openNavigation;
  final GameOfficialResult editOfficialResult;
  final GameCopyResult copyOfficalResult;

  Widget _buildAttendence(Game game, Season season, PlayerState playerState) {
    List<Widget> availability = <Widget>[];
    Map<Player, Attendance> availavilityResult = <Player, Attendance>{};

    if (season != null) {
      playerState.players.forEach((String key, Player player) {
        if (season.players.any((SeasonPlayer play) {
          return play.playerUid == key;
        })) {
          Attendance attend = Attendance.Maybe;
          if (game.attendance.containsKey(key)) {
            attend = game.attendance[key];
          }
          availavilityResult[player] = attend;
          availability.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Text(player.name)),
                new AttendanceIcon(attend),
              ],
            ),
          );
        }
      });
    }

    // Not started, show availability.
    return new ListTile(
      leading: const Icon(CommunityIcons.bookOpenVariant),
      title: new GestureDetector(
        onTap: () => openAttendence != null
            ? openAttendence(game, availavilityResult)
            : null,
        child: new Column(
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
    ThemeData theme = Theme.of(context);
    switch (details.result) {
      case GameResult.Unknown:
        if (inProgress) {
          title = TextSpan(
              text: Messages.of(context).resultinprogress(details),
              style: theme.textTheme.subhead);
        } else {
          title = TextSpan(
              text: Messages.of(context).resultunknown,
              style: theme.textTheme.subhead);
        }
        break;
      case GameResult.Loss:
        title = TextSpan(
            text: Messages.of(context).resultloss(details),
            style: theme.textTheme.subhead.copyWith(color: theme.errorColor));
        break;
      case GameResult.Win:
        title = TextSpan(
            text: Messages.of(context).resultwin(details),
            style: theme.textTheme.subhead.copyWith(color: theme.accentColor));
        break;
      case GameResult.Tie:
        title = TextSpan(
            text: Messages.of(context).resulttie(details),
            style: theme.textTheme.subhead);
        break;
    }

    if (official) {
      title = TextSpan(
          text: Messages.of(context).offical + "\n",
          style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.w600),
          children: <TextSpan>[title]);
    }

    return ListTile(
      onTap: () => _tapListTile(official, sharedData, details),
      leading: official
          ? (dontMatch
              ? Icon(Icons.error, color: theme.errorColor)
              : Icon(CommunityIcons.bookOpen))
          : Icon(CommunityIcons.bookOpenVariant),
      title: new RichText(text: title),
      subtitle: dontMatch
          ? Text(
              Messages.of(context).officialdontmatch,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: theme.errorColor),
            )
          : null,
    );
  }

  Widget _buildGame(BuildContext context, SingleTeamState teamState) {
    print(
        'lat: ${game.sharedData.place.latitude} long: ${game.sharedData.place.longitude} ${game.uid}');
    Marker marker = new Marker(
        game.sharedData.place.placeId,
        game.sharedData.place.address,
        game.sharedData.place.latitude.toDouble(),
        game.sharedData.place.longitude.toDouble());
    Uri uri = MapData.instance.provider
        .getStaticUriWithMarkers(<Marker>[marker], width: 900, height: 400);
    TimeOfDay day = new TimeOfDay.fromDateTime(game.sharedData.tzTime);
    TimeOfDay dayArrive = new TimeOfDay.fromDateTime(game.tzArriveTime);
    TimeOfDay dayEnd = new TimeOfDay.fromDateTime(game.sharedData.tzEndTime);
    String dateStr = MaterialLocalizations.of(context)
        .formatFullDate(game.sharedData.tzTime);
    String timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeStr =
        MaterialLocalizations.of(context).formatTimeOfDay(dayEnd);
    String tzShortName;
    if (game.sharedData.timezone != local.name) {
      tzShortName = " (" +
          getLocation(game.sharedData.timezone)
              .timeZone(game.sharedData.time.toInt())
              .abbr +
          ")";
    }
    print('${game.sharedData.timezone} $game.sharedData.tzTime}');
    String arriveAttimeStr;
    if (dayArrive.minute == day.minute && dayArrive.hour == day.hour) {
      arriveAttimeStr =
          MaterialLocalizations.of(context).formatTimeOfDay(dayArrive) +
              (tzShortName ?? "");
    } else {
      arriveAttimeStr = MaterialLocalizations.of(context).formatTimeOfDay(day) +
          (tzShortName ?? "");
    }
    Opponent opponent = teamState.opponents[game.opponentUids[0]];
    Season season = teamState.getSeason(game.seasonUid);

    ThemeData theme = Theme.of(context);

    Widget loadingWidget = new Column(
      children: <Widget>[
        new Text(Messages.of(context).loading),
        new CircularProgressIndicator()
      ],
    );

    List<Widget> body = <Widget>[];
    // Map view.
    body.add(
      new Container(
        height: 250.0,
        child: new Stack(
          children: <Widget>[
            new Center(
              child: CachedNetworkImage(
                placeholder: (context, url) => Center(
                  child: new Container(
                    padding: const EdgeInsets.all(20.0),
                    child: loadingWidget,
                  ),
                ),
                imageUrl: uri.toString(),
              ),
            ),
            new Positioned(
              right: 20.0,
              bottom: 0.0,
              child: new FloatingActionButton(
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
    body.add(
      new ListTile(
        leading: new TeamImage(
          team: teamState.team,
          width: 50.0,
          height: 50.0,
        ),
        title: new Text(teamState.team.name, style: theme.textTheme.title),
        subtitle:
            arriveAttimeStr != null && game.sharedData.type == EventType.Game
                ? new Text('arrive at ' + arriveAttimeStr,
                    style: theme.textTheme.subhead)
                : null,
        trailing: game.homegame ? const Icon(Icons.home) : null,
      ),
    );

    // Map details
    body.add(
      new ListTile(
        leading: new Icon(Icons.directions),
        title: new Text(
          dateStr +
              " " +
              timeStr +
              (game.sharedData.endTime == game.sharedData.time
                  ? ''
                  : " - " + endTimeStr + (tzShortName ?? "")),
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor),
        ),
        subtitle: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(game.sharedData.place.name ?? ''),
            new Text(
                game.sharedData.place.address ?? Messages.of(context).unknown),
          ],
        ),
      ),
    );

    // Results.
    if (game.sharedData.type == EventType.Game) {
      if (adding) {
        body.add(
          new ListTile(
            leading: new Icon(CommunityIcons.bookOpenVariant),
            title: new Text(Messages.of(context).gametype),
          ),
        );
      } else {
        if (game.result.inProgress == GameInProgress.NotStarted) {
          if (game.trackAttendance) {
            body.add(
              BlocBuilder(
                  cubit: BlocProvider.of<PlayerBloc>(context),
                  builder: (BuildContext context, PlayerState playerState) =>
                      _buildAttendence(game, season, playerState)),
            );
          }
        }
        // Show the live stuff if the game is close to starting.
        body.add(_buildGameResult(context, false, game.sharedData, game.result,
            game.result.inProgress == GameInProgress.InProgress, false));
        if (game.sharedData.time >
                new DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .millisecondsSinceEpoch &&
            !game.result.isGameFinished) {
          if (editResult != null) {
            body.add(ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text(Messages.of(context).addresultbutton),
                  onPressed: () => editResult(game),
                ),
              ],
            ));
          }
        }

        // Official results.
        GameFromOfficial officalData =
            GameFromOfficial(game.sharedData, game.leagueOpponentUid);
        body.add(_buildGameResult(
            context,
            true,
            game.sharedData,
            officalData,
            game.sharedData.officialResult.result == OfficialResult.InProgress,
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
    } else {
      // Tell people this is a practice or special event.
      if (game.sharedData.type == EventType.Practice) {
        body.add(
          new ListTile(
            leading: const Icon(Icons.train),
            title: new Text(Messages.of(context).trainingtype),
          ),
        );
      } else if (game.sharedData.type == EventType.Event) {
        body.add(
          new ListTile(
            leading: const Icon(Icons.plus_one),
            title: new Text(Messages.of(context).eventtype),
          ),
        );
      }
      // Attendance, possibly.
      if (!adding &&
          game.trackAttendance &&
          game.sharedData.time >
              new DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch) {
        body.add(
          BlocBuilder(
            cubit: BlocProvider.of<PlayerBloc>(context),
            builder: (BuildContext context, PlayerState playerState) =>
                _buildAttendence(game, season, playerState),
          ),
        );
      }
    }

    // Uniform
    if (game.uniform != null && game.uniform.isNotEmpty) {
      body.add(
        new ListTile(
          leading: const Icon(CommunityIcons.tshirtCrew),
          title: new Text(game.uniform == null ? 'fluff' : game.uniform),
        ),
      );
    }

    // Notes.
    if (game.notes != null && game.notes.isNotEmpty) {
      body.add(
        new ListTile(
          leading: const Icon(Icons.note),
          title: new Text(game.notes),
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
        new ExpansionTile(
          title: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                Messages.of(context).opponentseason(opponent, seasonName),
              ),
              new Text(
                Messages.of(context)
                    .opponentwinrecord(opponent, game.seasonUid, seasonName),
              ),
            ],
          ),
          initiallyExpanded: false,
          leading: const Icon(Icons.people),
          children: <Widget>[
            new TeamResultsBySeason(
              teamUid: teamState.team.uid,
              seasonUid: season.uid,
              opponentUid: game.opponentUids[0],
            ),
          ],
        ),
      );
      if (teamState.fullSeason.length > 1) {
        List<Widget> cols = <Widget>[];
        for (Season otherSeason in teamState.fullSeason) {
          if (otherSeason.uid != season.uid) {
            String seasonName;
            seasonName = otherSeason.name;

            cols.add(
              new Text(
                Messages.of(context).opponentseason(opponent, seasonName),
              ),
            );
            cols.add(
              new Text(
                Messages.of(context)
                    .opponentwinrecord(opponent, otherSeason.uid, seasonName),
              ),
            );
            cols.add(
              new TeamResultsBySeason(
                teamUid: teamState.team.uid,
                seasonUid: otherSeason.uid,
                opponentUid: game.opponentUids[0],
              ),
            );
          }
        }
        body.add(
          new ExpansionTile(
            title: new Text(Messages.of(context).previousSeasons),
            initiallyExpanded: false,
            leading: const Icon(Icons.people),
            children: cols,
          ),
        );
      }
    }

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: game.teamUid,
      builder: (BuildContext context, SingleTeamBloc bloc) => BlocListener(
        cubit: bloc,
        listener: (BuildContext context, SingleTeamState state) {
          if (state is SingleTeamLoaded) {
            bloc.add(SingleTeamLoadOpponents());
          }
        },
        child: BlocBuilder(
          cubit: bloc,
          builder: (BuildContext context, SingleTeamState teamState) =>
              _buildGame(context, teamState),
        ),
      ),
    );
  }
}
