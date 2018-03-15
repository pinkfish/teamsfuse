import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamplayers.dart';
import 'package:flutter_fuse/widgets/teams/teamdetails.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

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
      return new SingleChildScrollView(child:new TeamDetails(teamUid));
    }
    return new TeamPlayers(teamUid);
  }

  void _onEditTeam(BuildContext context) {
    Navigator.pushNamed(context, "EditTeam/" + teamUid);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = new List<Widget>();
    if (UserDatabaseData.instance.teams.containsKey(teamUid)) {
      if (UserDatabaseData.instance.teams[teamUid].isAdmin()) {
        actions.add(new FlatButton(
            onPressed: () {
              this._onEditTeam(context);
            },
            child: new Text(Messages.of(context).editbuttontext,
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white))),
          );
      }
    }
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
          actions: actions,
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
        body: _buildBody());
  }
}
