import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'dart:async';

class TeamOpponents extends StatefulWidget {
  final String _teamUid;

  TeamOpponents(this._teamUid);

  @override
  TeamOpponentsState createState() {
    return new TeamOpponentsState();
  }
}

class TeamOpponentsState extends State<TeamOpponents> {
  String _seasonUid;
  Team _team;
  StreamSubscription<UpdateReason> _updateStream;
  List<String> _opponentKeys;

  @override
  void initState() {
    super.initState();
    _team = UserDatabaseData.instance.teams[widget._teamUid];
    _opponentKeys = _team.opponents.keys.toList();
    _opponentKeys.sort((String uid1, String uid2) =>
        _team.opponents[uid1].name.compareTo(_team.opponents[uid2].name));
    updateSeason(_team.currentSeason);
    _updateStream = _team.thisTeamStream.listen((UpdateReason upd) {
      setState(() {
        _opponentKeys = _team.opponents.keys.toList();
        _opponentKeys.sort((String uid1, String uid2) =>
            _team.opponents[uid1].name.compareTo(_team.opponents[uid2].name));
      });
    });
  }

  @override
  void deactivate() {
    if (_updateStream != null) {
      _updateStream.cancel();
      _updateStream = null;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_updateStream != null) {
      _updateStream.cancel();
      _updateStream = null;
    }
    super.dispose();
  }

  void updateSeason(String seasonUid) {
    if (_team.seasons.containsKey(_team.currentSeason)) {
      _seasonUid = _team.currentSeason;
    }
  }

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    if (widget._teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(widget._teamUid)) {
      UserDatabaseData.instance.teams[widget._teamUid].seasons
          .forEach((key, season) {
        ret.add(new DropdownMenuItem(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }

  List<Widget> _buildOpponents() {
    List<Widget> ret = new List<Widget>();
    ThemeData theme = Theme.of(context);
    Season season = _team.seasons[_seasonUid];
    Future<Iterable<Game>> games = season.getGames();

    ret.add(
      new RichText(
        text: new TextSpan(
          text: Messages.of(context).opponentwithresult,
          style: theme.textTheme.title,
        ),
      ),
    );
    _opponentKeys.forEach((String uid) {
      Opponent op = _team.opponents[uid];
      WinRecord record;
      if (!op.record.containsKey(_seasonUid)) {
        return;
      }
      record = op.record[_seasonUid];

      ret.add(
        new ExpansionTile(
          title: new RichText(
            text: new TextSpan(
              style: theme.textTheme.subhead.copyWith(
                  color: record.win > record.loss
                      ? Colors.green
                      : record.win < record.loss
                          ? Colors.redAccent
                          : Colors.black),
              text: op.name +
                  " W:" +
                  record.win.toString() +
                  " L:" +
                  record.loss.toString() +
                  " T:" +
                  record.tie.toString(),
            ),
          ),
          initiallyExpanded: false,
          children: <Widget>[
            new FutureBuilder(
                future: games,
                builder: (BuildContext context,
                    AsyncSnapshot<Iterable<Game>> games) {
                  if (!games.hasData) {
                    return new Center(
                      child: new Text(Messages.of(context).loading),
                    );
                  }
                  if (games.data.length == 0) {
                    return new Center(
                      child: new Text(Messages.of(context).nogames),
                    );
                  } else {
                    List<Widget> newData = new List<Widget>();
                    games.data.forEach((Game game) {
                      if (game.type == EventType.Game &&
                          game.seasonUid == _seasonUid &&
                          game.opponentUid == uid) {
                        newData.add(new GameCard(game));
                      }
                    });
                    if (newData.length == 0) {
                      newData.add(new Text(Messages.of(context).nogames));
                    }
                    return new Column(
                      children: newData,
                    );
                  }
                }),
          ],
        ),
      );
    });
    ret.add(
      new RichText(
        text: new TextSpan(
          text: Messages.of(context).opponentwithnoresult,
          style: theme.textTheme.title,
        ),
      ),
    );
    _opponentKeys.forEach((String uid) {
      Opponent op = _team.opponents[uid];
      if (op.record.containsKey(_seasonUid)) {
        return;
      }

      ret.add(
        new ExpansionTile(
          title: new Text(op.name),
          initiallyExpanded: false,
          children: <Widget>[
            new FutureBuilder(
                future: games,
                builder: (BuildContext context,
                    AsyncSnapshot<Iterable<Game>> games) {
                  if (!games.hasData) {
                    return new Center(
                      child: new Text(Messages.of(context).loading),
                    );
                  }
                  if (games.data.length == 0) {
                    return new Center(
                      child: new Text(Messages.of(context).nogames),
                    );
                  } else {
                    List<Widget> newData = new List<Widget>();
                    games.data.forEach((Game game) {
                      if (game.type == EventType.Game &&
                          game.seasonUid == _seasonUid &&
                          game.opponentUid == uid) {
                        newData.add(new GameCard(game));
                      }
                    });
                    if (newData.length == 0) {
                      newData.add(new Text(Messages.of(context).nogames));
                    }
                    return new Column(
                      children: newData,
                    );
                  }
                }),
          ],
        ),
      );
    });

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messsages = Messages.of(context);

    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new DropdownButton(
              hint: new Text(messsages.seasonselect),
              value: _seasonUid,
              items: _buildItems(context),
              onChanged: (dynamic val) {
                print('changed $val');
                setState(() {
                  _seasonUid = val;
                });
              },
            ),
          ],
        ),
        new Expanded(
          child: new Container(
            constraints: new BoxConstraints(),
            margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            decoration: new BoxDecoration(color: theme.cardColor),
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildOpponents(),
              ),
            ),
          ),
        )
      ],
    );
  }
}
