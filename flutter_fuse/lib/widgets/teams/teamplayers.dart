import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';

class TeamPlayers extends StatefulWidget {
  final String _teamUid;

  TeamPlayers(this._teamUid);

  @override
  TeamPlayersState createState() {
    return new TeamPlayersState(this._teamUid);
  }
}

class TeamPlayersState extends State<TeamPlayers> {
  String _teamUid;
  String _seasonUid;
  Team _team;
  Season _season;

  TeamPlayersState(this._teamUid) {
    _team = UserDatabaseData.instance.teams[_teamUid];
    if (_team.seasons.containsKey(_team.currentSeason)) {
      _seasonUid = _team.currentSeason;
      _season = _team.seasons[_team.currentSeason];
    }
  }

  List<DropdownMenuItem> _buildItems(BuildContext context) {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    if (_teamUid != null &&
        UserDatabaseData.instance.teams.containsKey(_teamUid)) {
      UserDatabaseData.instance.teams[_teamUid].seasons.forEach((key, season) {
        ret.add(new DropdownMenuItem(
            child: new Text(season.name), value: season.uid));
      });
    }

    return ret;
  }

  List<Widget> _buildPlayers() {
    List<Widget> ret = new List<Widget>();

    print('players ${_season.toJSON()}');
    _season.players.forEach((SeasonPlayer player) {
      ret.add(new ListTile(
        leading: new PlayerImage(player.playerUid),
        title: new Text(player.displayName),
        subtitle: new Text(Messages.of(context).roleingame(player.role)),
      ));
    });
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messsages = Messages.of(context);

    return new Column(
      children: <Widget>[
        new DropdownButton(
            hint: new Text(messsages.seasonselect),
            value: _seasonUid,
            items: _buildItems(context),
            onChanged: (dynamic val) {
              print('changed $val');
              setState(() {
                _seasonUid = val;
                _season = _team.seasons[val];
              });
            }),
        new Expanded(
            child: new Container(
                constraints: new BoxConstraints(),
                margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                decoration: new BoxDecoration(color: theme.cardColor),
                child: new SingleChildScrollView(
                    child: new Column(children: _buildPlayers()))))
      ],
    );
  }
}
