import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/teams/teamplayers.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/teams/teamdetails.dart';

class TeamScreen extends StatefulWidget {
  String teamuid;

  TeamScreen(this.teamuid);

  @override
  TeamScreenState createState() {
    return new TeamScreenState(this.teamuid);
  }
}

class TeamScreenState extends State<TeamScreen> {
  int _tabIndex = 0;
  String teamUid;

  TeamScreenState(this.teamUid);

  Widget _buildBody() {
    if (_tabIndex == 0) {
      return new TeamDetails(teamUid);
    }
    return new TeamPlayers(teamUid);
  }

  void _onEditTeam(BuildContext context) {
    Navigator.pushNamed(context, "EditTeam/" + teamUid);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[
        new FlatButton(
            onPressed: () { this._onEditTeam(context); },
            child: new Text(Messages.of(context).editbuttontext,
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white))),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _tabIndex = index;
            });
          },
          currentIndex: _tabIndex,
          items: [
            new BottomNavigationBarItem(
              icon: const Icon(Icons.gamepad),
              title: new Text(Messages.of(context).gamedetails),
            ),
            new BottomNavigationBarItem(
                icon: const Icon(Icons.people),
                title: new Text(Messages.of(context).players))
          ]),
      body: _buildBody()

        );
  }
}