import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdetails.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addseasondialog.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addinvitetoleaguedialog.dart';

class LeagueScreen extends StatelessWidget {
  final String leagueUid;

  LeagueScreen(this.leagueUid);

  void _onEditLeague(BuildContext context) {
    Navigator.pushNamed(context, "/League/Edit/" + leagueUid);
  }

  void _doAction(BuildContext context, String action) {
    if (action == "season") {
      _addSeason(context);
    }
    if (action == "admin") {
      AddInviteToLeagueDialog.showAddLeagueOrTournamentInviteDialog(
          context, UserDatabaseData.instance.leagueOrTournments[leagueUid]);
    }
  }

  void _addSeason(BuildContext context) {
    AddSeasonDialog.showSeasonDialog(context, leagueUid);
  }

  Widget build(BuildContext context) {
    FloatingActionButton fab;
    List<Widget> actions = <Widget>[];
    if (UserDatabaseData.instance.leagueOrTournments.containsKey(leagueUid)) {
      print(
          'league stuff ${UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()}');
      if (UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()) {
             actions.add(
          new PopupMenuButton<String>(
            onSelected: (String str) => _doAction(context, str),
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                new PopupMenuItem<String>(
                  value: "season",
                  child: new Text(Messages.of(context).addseason),
                ),
                new PopupMenuItem<String>(
                  child: new Text(Messages.of(context).addadmin),
                  value: "admin",
                ),
              ];
            },
          ),
        );
      }
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new LeagueOrTournamentName(leagueUid),
        actions: actions,
      ),
      drawer: new FusedDrawer(DrawerMode.League),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: LeagueOrTournamentDetails(leagueUid),
        ),
      ),
    );
  }
}
