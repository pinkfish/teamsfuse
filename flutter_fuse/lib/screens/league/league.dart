import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdetails.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addseasondialog.dart';
import 'package:flutter_fuse/services/messages.dart';

class LeagueScreen extends StatelessWidget {
  final String leagueUid;

  LeagueScreen(this.leagueUid);

  void _onEditLeague(BuildContext context) {}

  void _doAction(BuildContext context, String action) {
    if (action == "season") {
      _addSeason(context);
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
        fab = new FloatingActionButton(
          onPressed: () => _onEditLeague(context),
          child: new Icon(Icons.edit),
        );
        actions.add(
          new PopupMenuButton<String>(
            onSelected: (String str) => _doAction(context, str),
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                new PopupMenuItem<String>(
                  value: "season",
                  child: new Text(Messages.of(context).addseason),
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
