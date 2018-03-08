import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class TeamPlayers extends StatefulWidget {
  String _teamUid;

  TeamPlayers(this._teamUid);

  @override
  TeamPlayersState createState() {
    return new TeamPlayersState(this._teamUid);
  }
}

class TeamPlayersState extends State<TeamPlayers> {
  String _teamUid;

  TeamPlayersState(this._teamUid);

  @override
  Widget build(BuildContext context) {
    return new Text('fluff');
  }
}
