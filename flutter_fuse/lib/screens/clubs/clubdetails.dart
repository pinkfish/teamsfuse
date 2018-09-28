import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/clubs/clubdetails.dart';
import 'package:flutter_fuse/widgets/clubs/clubmembers.dart';
import 'package:flutter_fuse/widgets/clubs/clubteams.dart';
import 'dart:async';

class ClubDetailsScreen extends StatefulWidget {
  final String clubUid;

  ClubDetailsScreen(this.clubUid);

  @override
  ClubDetailsScreenState createState() {
    return new ClubDetailsScreenState();
  }
}

class ClubDetailsScreenState extends State<ClubDetailsScreen> {
  int _tabIndex = 1;
  StreamSubscription<UpdateReason> _clubUpdates;

  ClubDetailsScreenState();

  @override
  void initState() {
    super.initState();
    _clubUpdates = UserDatabaseData.instance.clubStream
        .listen((UpdateReason reason) => setState(() => false));
  }

  @override
  void dispose() {
    super.dispose();
    _clubUpdates.cancel();
  }

  Widget _buildBody() {
    Club club = UserDatabaseData.instance.clubs[widget.clubUid];
    if (_tabIndex == 0) {
      return new Scrollbar(
        child: new SingleChildScrollView(
          child: new ClubDetails(club),
        ),
      );
    } else if (_tabIndex == 1) {
      return new ClubTeams(club);
    }
    print("$_tabIndex");
    return new ClubMembers(club);
  }

  void _select(String value) {
    if (value == "addadmin") {
      Navigator.pushNamed(context, "AddClubMember/" + widget.clubUid);
    } else if (value == "addteam") {
      Navigator.pushNamed(context, "AddClubTeam/" + widget.clubUid);
    } else if (value == "editclub") {
      Navigator.pushNamed(context, "EditClub/" + widget.clubUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = <Widget>[];
    FloatingActionButton fab;
    String title;
    if (UserDatabaseData.instance.clubs.containsKey(widget.clubUid)) {
      title = UserDatabaseData.instance.clubs[widget.clubUid].name;
      if (UserDatabaseData.instance.clubs[widget.clubUid].isAdmin()) {
        actions.add(
          new PopupMenuButton<String>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                new PopupMenuItem<String>(
                  value: "editclub",
                  child: new Text(Messages.of(context).editbuttontext),
                ),
                new PopupMenuItem<String>(
                  value: "addteam",
                  child: new Text(Messages.of(context).addteam),
                ),
                new PopupMenuItem(
                  value: 'addadmin',
                  child: Text(Messages.of(context).addadmin),
                )
              ];
            },
          ),
        );
        /*
        if (_tabIndex == 0) {
          fab = new FloatingActionButton(
            onPressed: _onEditClub,
            child: const Icon(Icons.edit),
          );
        } else if (_tabIndex == 1) {
          fab = FloatingActionButton(
              onPressed: _onAddTeam, child: const Icon(Icons.add));
        } else if (_tabIndex == 2) {
          fab = FloatingActionButton(
              onPressed: _onAddMember, child: const Icon(Icons.add));
        }
        */
      }
    } else {
      title = Messages.of(context).title;
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
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
              title: new Text(Messages.of(context).clubdetails),
            ),
            new BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              title: new Text(Messages.of(context).teams),
            ),
            new BottomNavigationBarItem(
              icon: const Icon(Icons.flag),
              title: new Text(Messages.of(context).members),
            ),
          ]),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
