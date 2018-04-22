import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamplayers.dart';
import 'package:flutter_fuse/widgets/teams/teamdetails.dart';
import 'package:flutter_fuse/widgets/teams/teamopponents.dart';
import 'package:flutter_fuse/services/databasedetails.dart';

class TeamScreen extends StatefulWidget {
  final String teamUid;

  TeamScreen(this.teamUid);

  @override
  TeamScreenState createState() {
    return new TeamScreenState();
  }
}

class TeamScreenState extends State<TeamScreen> {
  int _tabIndex = 0;

  TeamScreenState();

  Widget _buildBody() {
    if (_tabIndex == 0) {
      return new Scrollbar(
        child: new SingleChildScrollView(
          child: new TeamDetails(widget.teamUid),
        ),
      );
    } else if (_tabIndex == 2) {
      return  new TeamOpponents(widget.teamUid);
    }
    print("${_tabIndex}");
    return new TeamPlayers(widget.teamUid);
  }

  void _onEditTeam(BuildContext context) {
    Navigator.pushNamed(context, "EditTeam/" + widget.teamUid);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = new List<Widget>();
    if (UserDatabaseData.instance.teams.containsKey(widget.teamUid)) {
      if (UserDatabaseData.instance.teams[widget.teamUid]
          .isAdmin(UserDatabaseData.instance.players)) {
        actions.add(
          new FlatButton(
            onPressed: () {
              this._onEditTeam(context);
            },
            child: new Text(
              Messages.of(context).editbuttontext,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
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
              title: new Text(Messages.of(context).players),
            ),
            new BottomNavigationBarItem(
              icon: const Icon(Icons.flag),
              title: new Text(Messages.of(context).opponent),
            ),
          ]),
      body: _buildBody(),
    );
  }
}
