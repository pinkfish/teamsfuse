import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
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

  void initState() {
    super.initState();
    Team team = UserDatabaseData.instance.teams[widget.game.teamUid];
    if (team != null) {
      teamUpdate = team.thisTeamStream.listen((data) {
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
    url += "&destination=" + Uri.encodeComponent(widget.game.place.address);
    if (widget.game.place.placeId != null) {
      url += "&destination_place_id=" +
          Uri.encodeComponent(widget.game.place.placeId);
    }
    launch(url);
  }

  void _editResult() async {
    // Call up a dialog to edit the result.
    await showDialog(
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
        widget.game.updateFirestorAttendence(player.uid, attend);
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
          widget.game.updateFirestorAttendence(player.uid, attend);
        });
      }
    }
  }

  Widget _buildAttendence(Season season) {
    List<Widget> availability = [];
    Map<Player, Attendance> availavilityResult = new Map<Player, Attendance>();

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
    this._attendence = availavilityResult;

    // Not started, show availability.
    return new ListTile(
      leading: const Icon(CommunityIcons.bookopenvariant),
      title: new GestureDetector(
        onTap: _openAttendance,
        child: new Column(
          children: availability,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'lat: ${widget.game.place.latitude} long: ${widget.game.place.longitude} ${widget.game.uid}');
    Marker marker = new Marker(
        widget.game.place.placeId,
        widget.game.place.address,
        widget.game.place.latitude.toDouble(),
        widget.game.place.longitude.toDouble());
    var uri = MapData.instance.provider
        .getStaticUriWithMarkers([marker], width: 900, height: 400);
    TimeOfDay day = new TimeOfDay.fromDateTime(widget.game.tzTime);
    TimeOfDay dayArrive = new TimeOfDay.fromDateTime(widget.game.tzArriveTime);
    TimeOfDay dayEnd = new TimeOfDay.fromDateTime(widget.game.tzEndTime);
    String dateStr =
        MaterialLocalizations.of(context).formatFullDate(widget.game.tzTime);
    String timeStr = MaterialLocalizations.of(context).formatTimeOfDay(day);
    String endTimeStr =
        MaterialLocalizations.of(context).formatTimeOfDay(dayEnd);
    String tzShortName;
    if (widget.game.timezone != local.name) {
      tzShortName = " (" +
          getLocation(widget.game.timezone).timeZone(widget.game.time).abbr +
          ")";
    }
    print('${widget.game.timezone} ${widget.game.tzTime}');
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
    Opponent opponent = team.opponents[widget.game.opponentUid];
    Season season = team.seasons[widget.game.seasonUid];

    ThemeData theme = Theme.of(context);

    Widget loadingWidget = new Column(
      children: <Widget>[
        new Text(Messages.of(context).loading),
        new CircularProgressIndicator()
      ],
    );

    List<Widget> body = new List<Widget>();
    // Map view.
    body.add(
      new Container(
        height: 250.0,
        child: new Stack(
          children: [
            new Center(
              child: new CachedNetworkImage(
                placeholder: new Center(
                  child: new Container(
                    padding: const EdgeInsets.all(20.0),
                    child: loadingWidget,
                  ),
                ),
                imageNow: uri.toString(),
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
        leading: new TeamImage(widget.game.teamUid, width: 50.0, height: 50.0),
        title: new Text(team.name, style: theme.textTheme.title),
        subtitle: arriveAttimeStr != null && widget.game.type == EventType.Game
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
              (widget.game.endTime == widget.game.time
                  ? ''
                  : " - " + endTimeStr + (tzShortName ?? "")),
          style: theme.textTheme.subhead.copyWith(color: theme.accentColor),
        ),
        subtitle: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(widget.game.place.name ?? ''),
            new Text(widget.game.place.address ?? Messages.of(context).unknown),
          ],
        ),
      ),
    );

    // Results.
    if (widget.game.type == EventType.Game) {
      if (widget.adding) {
        body.add(
          new ListTile(
            leading: new Icon(CommunityIcons.bookopenvariant),
            title: new Text(Messages.of(context).gametype),
          ),
        );
      } else {
        String title;
        TextStyle resultStyle;
        if (widget.game.result.inProgress == GameInProgress.NotStarted) {
          if (widget.game.trackAttendance) {
            body.add(_buildAttendence(season));
          }
        }
        // Show the live stuff if the game is close to starting.
        if (widget.game.time >
            new DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch) {}
        // Started.
        switch (widget.game.result.result) {
          case GameResult.Unknown:
            if (widget.game.result.inProgress != GameInProgress.NotStarted) {
              title = Messages.of(context).resultinprogress(widget.game.result);
              resultStyle = theme.textTheme.subhead;
            } else {
              title = Messages.of(context).resultunknown;
              resultStyle = theme.textTheme.subhead;
            }
            break;
          case GameResult.Loss:
            title = Messages.of(context).resultloss(widget.game.result);
            resultStyle =
                theme.textTheme.subhead.copyWith(color: theme.errorColor);
            break;
          case GameResult.Win:
            title = Messages.of(context).resultwin(widget.game.result);
            resultStyle =
                theme.textTheme.subhead.copyWith(color: theme.accentColor);
            break;
          case GameResult.Tie:
            title = Messages.of(context).resulttie(widget.game.result);
            resultStyle = theme.textTheme.subhead;
            break;
        }
        body.add(
          new ListTile(
            onTap: this._editResult,
            leading: new Icon(CommunityIcons.bookopenvariant),
            title: new Text(title, style: resultStyle),
          ),
        );
      }
    } else {
      // Tell people this is a practice or special event.
      if (widget.game.type == EventType.Practice) {
        body.add(
          new ListTile(
            leading: const Icon(Icons.train),
            title: new Text(Messages.of(context).trainingtype),
          ),
        );
      } else if (widget.game.type == EventType.Event) {
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
          widget.game.time >
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
          leading: const Icon(CommunityIcons.tshirtcrew),
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
    if (widget.game.type == EventType.Game && !widget.adding) {
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
              future: season.getGames(),
              opponentUid: widget.game.opponentUid,
            ),
          ],
        ),
      );
      if (team.seasons.length > 1) {
        List<Widget> cols = [];
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
                Messages
                    .of(context)
                    .opponentwinrecord(opponent, otherSeason.uid, seasonName),
              ),
            );
            cols.add(
              new TeamResultsStreamFuture(
                future: otherSeason.getGames(),
                opponentUid: widget.game.opponentUid,
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
