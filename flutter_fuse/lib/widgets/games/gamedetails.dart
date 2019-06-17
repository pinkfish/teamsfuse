import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:flutter_fuse/services/map_view/marker.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/attendancedialog.dart';
import 'package:flutter_fuse/widgets/games/attendanceicon.dart';
import 'package:flutter_fuse/widgets/games/editresultdialog.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/game/gamefromofficial.dart';
import 'package:timezone/timezone.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/savingoverlay.dart';
import 'officalresultdialog.dart';
import 'teamresultsstreamfuture.dart';

class GameDetails extends StatefulWidget {
  GameDetails(this.gameBloc, {this.adding = false});

  final SingleGameBloc gameBloc;
  final bool adding;

  @override
  GameDetailsState createState() {
    return new GameDetailsState();
  }
}

class GameDetailsState extends State<GameDetails> {
  Map<Player, Attendance> _attendence;

  void openNavigation(Game game) {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" + Uri.encodeComponent(game.sharedData.place.address);
    if (game.sharedData.place.placeId != null) {
      url += "&destination_place_id=" +
          Uri.encodeComponent(game.sharedData.place.placeId);
    }
    launch(url);
  }

  void _editResult() async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        print("$widget");
        return new EditResultDialog(widget.gameBloc);
      },
    );
  }

  void _openAttendance() async {
    if (_attendence.length == 1) {
      // Do a simple picker popup.
      Player player = _attendence.keys.first;
      Attendance current = _attendence[player];

      Attendance attend = await showDialog<Attendance>(
          context: context,
          builder: (BuildContext context) {
            return new AttendanceDialog(current: current);
          });
      if (attend != null) {
        widget.gameBloc.dispatch(SingleGameUpdateAttendance(
            playerUid: player.uid, attendance: attend));
      }
    } else {
      Map<Player, Attendance> attend = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new MultipleAttendanceDialog(_attendence);
        },
      );
      if (attend != null) {
        attend.forEach((Player player, Attendance attend) {
          widget.gameBloc.dispatch(SingleGameUpdateAttendance(
              playerUid: player.uid, attendance: attend));
        });
      }
    }
  }

  Widget _buildAttendence(Game game, Season season) {
    List<Widget> availability = <Widget>[];
    Map<Player, Attendance> availavilityResult = <Player, Attendance>{};

    if (season != null) {
      PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
      playerBloc.currentState.players.forEach((String key, Player player) {
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
    _attendence = availavilityResult;

    // Not started, show availability.
    return new ListTile(
      leading: const Icon(CommunityIcons.bookOpenVariant),
      title: new GestureDetector(
        onTap: _openAttendance,
        child: new Column(
          children: availability,
        ),
      ),
    );
  }

  Widget _buildGameResult(bool official, GameSharedData sharedData,
      GameResultSharedDetails details, bool inProgress, bool dontMatch) {
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
      onTap: official
          ? () => _editOfficialResult(sharedData, details)
          : _editResult,
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

  ///
  /// Try and edit the offical results, this is only possible if the
  /// user is an admin for the league itself.  Otherwise we can
  /// ask if they want to copy the results.
  ///
  void _editOfficialResult(
      GameSharedData sharedData, GameResultSharedDetails offical) {
    LeagueOrTournamentBloc leagueOrTournamentBloc =
        BlocProvider.of<LeagueOrTournamentBloc>(context);

    if (leagueOrTournamentBloc.currentState.leagueOrTournaments
        .containsKey(sharedData.leagueUid)) {
      if (leagueOrTournamentBloc
          .currentState.leagueOrTournaments[sharedData.leagueUid]
          .isAdmin()) {
        // Show it and forget it.
        showDialog<bool>(
            context: context,
            builder: (BuildContext context) =>
                OfficialResultDialog(sharedData));
        return;
      }
    }
    _copyOfficialResult(sharedData, offical);
  }

  ///
  /// Copy the current score/stuff from the official results.
  ///
  void _copyOfficialResult(
      GameSharedData sharedData, GameResultSharedDetails details) async {
    bool ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Messages.of(context).useofficialresultbutton),
            content: RichText(
                text: TextSpan(
                    text: Messages.of(context).useofficialresultdialog,
                    children: <TextSpan>[
                  TextSpan(text: Messages.of(context).resultinprogress(details))
                ])),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () => Navigator.pop(context, true),
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        });
    if (ret != null && ret) {
      // Copy the result over and save.
      GameResultDetailsBuilder newResult = GameResultDetailsBuilder();
      newResult.scores[GamePeriod.regulation] = details.regulationResult;
      if (details.overtimeResult != null) {
        newResult.scores[GamePeriod.overtime] = details.overtimeResult;
      }
      if (details.penaltyResult != null) {
        newResult.scores[GamePeriod.penalty] = details.penaltyResult;
      }
      newResult.result = details.result;
      widget.gameBloc
          .dispatch(SingleGameUpdateResult(result: newResult.build()));
    }
  }

  Widget buildGame(BuildContext context, Game game) {
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
    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
    Team team = teamBloc.currentState.getTeam(game.teamUid);
    Opponent opponent = team.opponents[game.opponentUids[0]];
    Season season = team.seasons[game.seasonUid];

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
              child: new CachedNetworkImage(
                placeholder: new Center(
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
                onPressed: () => openNavigation(game),
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
          team: team,
          width: 50.0,
          height: 50.0,
        ),
        title: new Text(team.name, style: theme.textTheme.title),
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
      if (widget.adding) {
        body.add(
          new ListTile(
            leading: new Icon(CommunityIcons.bookOpenVariant),
            title: new Text(Messages.of(context).gametype),
          ),
        );
      } else {
        if (game.result.inProgress == GameInProgress.NotStarted) {
          if (game.trackAttendance) {
            body.add(_buildAttendence(game, season));
          }
        }
        // Show the live stuff if the game is close to starting.
        body.add(_buildGameResult(false, game.sharedData, game.result,
            game.result.inProgress == GameInProgress.InProgress, false));
        if (game.sharedData.time >
                new DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .millisecondsSinceEpoch &&
            !game.result.isGameFinished) {
          body.add(ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text(Messages.of(context).addresultbutton),
                onPressed: _editResult,
              ),
            ],
          ));
        }

        // Official results.
        GameFromOfficial officalData =
            GameFromOfficial(game.sharedData, game.leagueOpponentUid);
        body.add(_buildGameResult(
            true,
            game.sharedData,
            officalData,
            game.sharedData.officialResults.result == OfficialResult.InProgress,
            officalData.isSameAs(game.result)));
        if (!officalData.isSameAs(game.result)) {
          body.add(ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text(Messages.of(context).useofficialresultbutton),
                onPressed: () =>
                    _copyOfficialResult(game.sharedData, officalData),
              ),
            ],
          ));
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
      if (!widget.adding &&
          game.trackAttendance &&
          game.sharedData.time >
              new DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch) {
        body.add(_buildAttendence(game, season));
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
    if (game.sharedData.type == EventType.Game && !widget.adding) {
      String seasonName;
      if (team.seasons.containsKey(game.seasonUid)) {
        seasonName = team.seasons[game.seasonUid].name;
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
            new TeamResultsStreamFuture(
              teamUid: team.uid,
              seasonUid: season.uid,
              opponentUid: game.opponentUids[0],
            ),
          ],
        ),
      );
      if (team.seasons.length > 1) {
        List<Widget> cols = <Widget>[];
        for (Season otherSeason in team.seasons.values) {
          if (otherSeason.uid != season.uid) {
            String seasonName;
            if (team.seasons.containsKey(otherSeason.uid)) {
              seasonName = team.seasons[otherSeason.uid].name;
            } else {
              seasonName = Messages.of(context).unknown;
            }

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
              new TeamResultsStreamFuture(
                teamUid: team.uid,
                seasonUid: season.uid,
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
    return BlocListener(
      bloc: widget.gameBloc,
      listener: (BuildContext context, SingleGameState state) {
        if (state is SingleGameDeleted) {
          Navigator.pop(context);
        }

        if (state is SingleGameSaveFailed) {}
      },
      child: BlocBuilder(
        bloc: widget.gameBloc,
        builder: (BuildContext context, SingleGameState state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return SavingOverlay(
            saving: state is SingleGameSaving,
            child: buildGame(context, state.game),
          );
        },
      ),
    );
  }
}
