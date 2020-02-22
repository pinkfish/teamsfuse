import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/teams/teamdetails.dart';
import 'package:flutter_fuse/widgets/teams/teamopponents.dart';
import 'package:flutter_fuse/widgets/teams/teamplayers.dart';
import 'package:flutter_fuse/widgets/teams/teamsettings.dart';
import 'package:fusemodel/blocs.dart';

import '../../widgets/blocs/singleteamprovider.dart';

class TeamScreen extends StatefulWidget {
  TeamScreen(this.teamUid);

  final String teamUid;

  @override
  TeamScreenState createState() {
    return new TeamScreenState();
  }
}

class TeamScreenState extends State<TeamScreen> {
  TeamScreenState();

  int _tabIndex = 0;

  Widget _buildBody(SingleTeamBloc singleTeamBloc) {
    if (_tabIndex == 0) {
      return new Scrollbar(
        child: new SingleChildScrollView(
          child: new TeamDetails(widget.teamUid),
        ),
      );
    } else if (_tabIndex == 2) {
      return new TeamOpponents(singleTeamBloc);
    } else if (_tabIndex == 3) {
      return new TeamSettings(widget.teamUid);
    }
    print("$_tabIndex");
    return new TeamPlayers(widget.teamUid);
  }

  void _onEditTeam(BuildContext context) {
    Navigator.pushNamed(context, "EditTeam/" + widget.teamUid);
  }

  void _select(String choice, SingleTeamBloc singleTeamBloc) async {
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
      singleTeamBloc
          .add(SingleTeamArchive(archive: !singleTeamBloc.state.team.archived));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = <Widget>[];
    FloatingActionButton fab;
    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (BuildContext contextl, SingleTeamBloc singleTeamBloc) =>
          BlocBuilder(
        bloc: singleTeamBloc,
        builder: (BuildContext context, SingleTeamState state) {
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
            return Text(Messages.of(context).loading);
          }
          if (state.isAdmin() && _tabIndex == 0) {
            actions.add(
              new PopupMenuButton<String>(
                onSelected: (String str) => _select(str, singleTeamBloc),
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
                    new PopupMenuItem<String>(
                      value: 'archive',
                      child: Text(Messages.of(context).archiveteam),
                    )
                  ];
                },
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: new Text(
                Messages.of(context).titlewith(singleTeamBloc.state.team.name),
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
            floatingActionButton: BlocBuilder(
              bloc: singleTeamBloc,
              builder: (BuildContext context, SingleTeamState state) {
                if (state.isAdmin() && _tabIndex == 0) {
                  fab = new FloatingActionButton(
                    onPressed: () => _onEditTeam(context),
                    child: new Icon(Icons.edit),
                  );
                  return fab;
                }
                return new Text("");
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: _buildBody(singleTeamBloc),
          );
        },
      ),
    );
  }
}
