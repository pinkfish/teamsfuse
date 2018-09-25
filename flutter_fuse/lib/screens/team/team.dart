import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamplayers.dart';
import 'package:flutter_fuse/widgets/teams/teamdetails.dart';
import 'package:flutter_fuse/widgets/teams/teamopponents.dart';
import 'package:flutter_fuse/widgets/teams/teamsettings.dart';
import 'package:fusemodel/fusemodel.dart';

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
      return new TeamOpponents(widget.teamUid);
    } else if (_tabIndex == 3) {
      return new TeamSettings(widget.teamUid);
    }
    print("$_tabIndex");
    return new TeamPlayers(widget.teamUid);
  }

  void _onEditTeam(BuildContext context) {
    Navigator.pushNamed(context, "EditTeam/" + widget.teamUid);
  }

  void _select(String choice) async {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {});
    if (choice == 'settings') {
      // Show a dialog and then delete it!
      Navigator.pushNamed(context, "TeamSettings/" + widget.teamUid);
    }
    if (choice == "club") {
      Navigator.pushNamed(context, "TeamClub/" + widget.teamUid);
    }
    if (choice == 'archive') {
      Team team = UserDatabaseData.instance.teams[widget.teamUid];
      team.archived = !team.archived;
      await team.updateFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = <Widget>[];
    FloatingActionButton fab;
    if (UserDatabaseData.instance.teams.containsKey(widget.teamUid)) {
      print(
          'tean stuff ${UserDatabaseData.instance.teams[widget.teamUid].isAdmin()}');
      if (UserDatabaseData.instance.teams[widget.teamUid].isAdmin() &&
          _tabIndex == 0) {
        fab = new FloatingActionButton(
          onPressed: () => _onEditTeam(context),
          child: new Icon(Icons.edit),
        );
        actions.add(
          new PopupMenuButton<String>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                new PopupMenuItem<String>(
                  value: "settings",
                  child: new Text(Messages.of(context).settings),
                ),
                new PopupMenuItem<String>(
                  value: "club",
                  child: new Text(Messages.of(context).club),
                ),
                new PopupMenuItem(
                  value: 'archive',
                  child: Text(Messages.of(context).archiveteam),
                )
              ];
            },
          ),
        );
      }
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context)
              .titlewith(UserDatabaseData.instance.teams[widget.teamUid].name),
        ),
        actions: actions,
      ),
      bottomNavigationBar: new BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _tabIndex = index;
            });
          },
          currentIndex: _tabIndex,
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
              icon: const Icon(Icons.gamepad),
              title: new Text(Messages.of(context).details),
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
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
