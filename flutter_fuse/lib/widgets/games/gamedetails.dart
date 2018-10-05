import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_fuse/services/map_view/marker.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/games/editresultdialog.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:flutter_fuse/widgets/games/attendanceicon.dart';
import 'package:flutter_fuse/widgets/games/attendancedialog.dart';
import 'package:flutter_fuse/widgets/games/multipleattendencedialog.dart';
import 'teamresultsstreamfuture.dart';
import 'package:timezone/timezone.dart';
import 'package:fusemodel/src/game/gamefromofficial.dart';
import 'officalresultdialog.dart';

import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

class GameDetails extends StatefulWidget {
  GameDetails(this.game, {this.adding = false});

  final Game game;
  final bool adding;

  @override
  GameDetailsState createState() {
    return new GameDetailsState();
  }
}

class GameDetailsState extends State<GameDetails> {
  StreamSubscription<UpdateReason> teamUpdate;
  Map<Player, Attendance> _attendence;
  StreamSubscription<UpdateReason> _subscription;

  @override
  void initState() {
    super.initState();
    Team team = UserDatabaseData.instance.teams[widget.game.teamUid];
    if (team != null) {
      teamUpdate = team.thisTeamStream.listen((UpdateReason data) {
        setState(() {});
      });
    }
    // Refresh the details on a change (only if the game exists).
    if (widget.game.uid != null && widget.game.thisGameStream != null) {
      _subscription = widget.game.thisGameStream.listen((UpdateReason reason) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
    teamUpdate?.cancel();
    teamUpdate = null;
  }

  void openNavigation() {
    String url = "https://www.google.com/maps/dir/?api=1";
    url += "&destination=" +
        Uri.encodeComponent(widget.game.sharedData.place.address);
    if (widget.game.sharedData.place.placeId != null) {
      url += "&destination_place_id=" +
          Uri.encodeComponent(widget.game.sharedData.place.placeId);
    }
    launch(url);
  }

  void _editResult() async {
    // Call up a dialog to edit the result.
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        print("$widget");
        return new EditResultDialog(widget.game);
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
        widget.game.updateFirestoreAttendence(player.uid, attend);
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
          widget.game.updateFirestoreAttendence(player.uid, attend);
        });
      }
    }
  }

  Widget _buildAttendence(Season season) {
    List<Widget> availability = <Widget>[];
    Map<Player, Attendance> availavilityResult = <Player, Attendance>{};

    if (season != null) {
      UserDatabaseData.instance.players.forEach((String key, Player player) {
        if (season.players.any((SeasonPlayer play) {
          return play.playerUid == key;
        })) {
          Attendance attend = Attendance.Maybe;
          if (widget.game.attendance.containsKey(key)) {
            attend = widget.game.attendance[key];
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

  Widget _buildGameResult(bool official, GameResultSharedDetails details,
      bool inProgress, bool dontMatch) {
    // Started.
    TextSpan title;
    TextStyle resultStyle;
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
      onTap: official ? () => _editOfficialResult(details) : _editResult,
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
  void _editOfficialResult(GameResultSharedDetails offical) {
    if (UserDatabaseData.instance.leagueOrTournments
        .containsKey(widget.game.sharedData.leagueUid)) {
      if (UserDatabaseData
          .instance.leagueOrTournments[widget.game.sharedData.leagueUid]
          .isAdmin()) {
        // Show it and forget it.
        showDialog<bool>(
            context: context,
            builder: (BuildContext context) =>
                OfficialResultDialog(widget.game.sharedData));
        return;
      }
    }
    _copyOfficialResult(offical);
  }

  ///
  /// Copy the current score/stuff from the official results.
  ///
  void _copyOfficialResult(GameResultSharedDetails details) async {
    bool ret = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Messages.of(context).useofficialresultbutton),
            content: RichText(
                text: TextSpan(
                    text: Messages.of(context).useofficialresultdialog,
                    children: [
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
      GameResultDetails newResult =
          new GameResultDetails.copy(widget.game.result);
      newResult.scores[GamePeriod.regulation] = details.regulationResult;
      if (details.overtimeResult != null) {
        newResult.scores[GamePeriod.overtime] = details.overtimeResult;
      }
      if (details.penaltyResult != null) {
        newResult.scores[GamePeriod.penalty] = details.penaltyResult;
      }
      newResult.result = details.result;
      await widget.game.updateFirestoreResult(newResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'lat: ${widget.game.sharedData.place.latitude} long: ${widget.game.sharedData.place.longitude} ${widget.game.uid}');
    Marker marker = new Marker(
        widget.game.sharedData.place.placeId,
        widget.game.sharedData.place.address,
        widget.game.sharedData.place.latitude.toDouble(),
        widget.game.sharedData.place.longitude.toDouble());
    Uri uri = MapData.instance.provider
        .getStaticUriWithMarkers(<Marker>[marker], width: 900, height: 400);
    TimeOfDay day = new TimeOfDay.fromDateTime(widget.game.sharedData.tzTime);
    TimeOfDay dayArrive = new TimeOfDay.fromDateTime(widget.game.tzArriveTime);
    TimeOfDay dayEnd =
        new TimeOfDay.fromDateTime(widget.game.sharedData.tzEndTime);
    String dateStr = MaterialLocalizations.of(context)
        .formatFullDate(widget.game.sharedData.tzTime);
    String timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeStr =
        MaterialLocalizations.of(context).formatTimeOfDay(dayEnd);
    String tzShortName;
    if (widget.game.sharedData.timezone != local.name) {
      tzShortName = " (" +
          getLocation(widget.game.sharedData.timezone)
              .timeZone(widget.game.sharedData.time.toInt())
              .abbr +
          ")";
    }
    print(
        '${widget.game.sharedData.timezone} ${widget.game.sharedData.tzTime}');
    String arriveAttimeStr;
    if (dayArrive.minute == day.minute && dayArrive.hour == day.hour) {
      arriveAttimeStr =
          MaterialLocalizations.of(context).formatTimeOfDay(dayArrive) +
              (tzShortName ?? "");
    } else {
      arriveAttimeStr = MaterialLocalizations.of(context).formatTimeOfDay(day) +
          (tzShortName ?? "");
    }
    Team team = UserDatabaseData.instance.teams[widget.game.teamUid];
    Opponent opponent = team.opponents[widget.game.opponentUids[0]];
    Season season = team.seasons[widget.game.seasonUid];

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
                onPressed: openNavigation,
                child: const Icon(Icons.directions),
                backgroundColor: Colors.orange,
                heroTag: widget.game.uid,
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
          team: UserDatabaseData.instance.teams[widget.game.teamUid],
          width: 50.0,
          height: 50.0,
        ),
        title: new Text(team.name, style: theme.textTheme.title),
        subtitle: arriveAttimeStr != null &&
                widget.game.sharedData.type == EventType.Game
            ? new Text('arrive at ' + arriveAttimeStr,
                style: theme.textTheme.subhead)
            : null,
        trailing: widget.game.homegame ? const Icon(Icons.home) : null,
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
              (widget.game.sharedData.endTime == widget.game.sharedData.time
                  ? ''
                  : " - " + endTimeStr + (tzShortName ?? "")),
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor),
        ),
        subtitle: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(widget.game.sharedData.place.name ?? ''),
            new Text(widget.game.sharedData.place.address ??
                Messages.of(context).unknown),
          ],
        ),
      ),
    );

    // Results.
    if (widget.game.sharedData.type == EventType.Game) {
      if (widget.adding) {
        body.add(
          new ListTile(
            leading: new Icon(CommunityIcons.bookOpenVariant),
            title: new Text(Messages.of(context).gametype),
          ),
        );
      } else {
        if (widget.game.result.inProgress == GameInProgress.NotStarted) {
          if (widget.game.trackAttendance) {
            body.add(_buildAttendence(season));
          }
        }
        // Show the live stuff if the game is close to starting.
        body.add(_buildGameResult(false, widget.game.result,
            widget.game.result.inProgress == GameInProgress.InProgress, false));
        if (widget.game.sharedData.time >
                new DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .millisecondsSinceEpoch &&
            !widget.game.result.isGameFinished) {
          body.add(ButtonBar(
            children: [
              FlatButton(
                child: Text(Messages.of(context).addresultbutton),
                onPressed: _editResult,
              ),
            ],
          ));
        }

        // Official results.
        GameFromOfficial officalData =
            GameFromOfficial(widget.game.sharedData, widget.game.leagueOpponentUid);
        body.add(_buildGameResult(
            true,
            officalData,
            widget.game.sharedData.officialResults.result ==
                OfficialResult.InProgress,
            officalData.isSameAs(widget.game.result)));
        if (!officalData.isSameAs(widget.game.result)) {
          body.add(ButtonBar(
            children: [
              FlatButton(
                child: Text(Messages.of(context).useofficialresultbutton),
                onPressed: () => _copyOfficialResult(officalData),
              ),
            ],
          ));
        }
      }
    } else {
      // Tell people this is a practice or special event.
      if (widget.game.sharedData.type == EventType.Practice) {
        body.add(
          new ListTile(
            leading: const Icon(Icons.train),
            title: new Text(Messages.of(context).trainingtype),
          ),
        );
      } else if (widget.game.sharedData.type == EventType.Event) {
        body.add(
          new ListTile(
            leading: const Icon(Icons.plus_one),
            title: new Text(Messages.of(context).eventtype),
          ),
        );
      }
      // Attendance, possibly.
      if (!widget.adding &&
          widget.game.trackAttendance &&
          widget.game.sharedData.time >
              new DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .millisecondsSinceEpoch) {
        body.add(_buildAttendence(season));
      }
    }

    // Uniform
    if (widget.game.uniform != null && widget.game.uniform.isNotEmpty) {
      body.add(
        new ListTile(
          leading: const Icon(CommunityIcons.tshirtCrew),
          title: new Text(
              widget.game.uniform == null ? 'fluff' : widget.game.uniform),
        ),
      );
    }

    // Notes.
    if (widget.game.notes != null && widget.game.notes.isNotEmpty) {
      body.add(
        new ListTile(
          leading: const Icon(Icons.note),
          title: new Text(widget.game.notes),
        ),
      );
    }

    // Opponent last games.
    if (widget.game.sharedData.type == EventType.Game && !widget.adding) {
      String seasonName;
      if (team.seasons.containsKey(widget.game.seasonUid)) {
        seasonName = team.seasons[widget.game.seasonUid].name;
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
                Messages.of(context).opponentwinrecord(
                    opponent, widget.game.seasonUid, seasonName),
              ),
            ],
          ),
          initiallyExpanded: false,
          leading: const Icon(Icons.people),
          children: <Widget>[
            new TeamResultsStreamFuture(
              teamUid: team.uid,
              seasonUid: season.uid,
              opponentUid: widget.game.opponentUids[0],
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
                opponentUid: widget.game.opponentUids[0],
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
}
