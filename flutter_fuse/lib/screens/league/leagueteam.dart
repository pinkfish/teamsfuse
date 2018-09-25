import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteam.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addinvitetoteamdialog.dart';

class LeagueTeamScreen extends StatelessWidget {
  final String leagueTeamUid;
  final String leagueUid;
  final String leagueSeasonUid;

  LeagueTeamScreen(this.leagueUid, this.leagueSeasonUid, this.leagueTeamUid);

  void _doAction(BuildContext context, String action) {
    if (action == "invite") {
      AddInviteToTeamDialog.showAddTeamInviteDialogByUid(
          context, leagueUid, leagueSeasonUid, leagueTeamUid);
    }
  }

  Widget build(BuildContext context) {
    FloatingActionButton fab;
    List<Widget> actions = <Widget>[];

    if (UserDatabaseData.instance.leagueOrTournments.containsKey(leagueUid)) {
      if (UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()) {
        actions.add(
          new PopupMenuButton<String>(
            onSelected: (String str) => _doAction(context, str),
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                new PopupMenuItem<String>(
                  value: "invite",
                  child: new Text(Messages.of(context).addteamadmin),
                ),
              ];
            },
          ),
        );
      }
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new LeagueOrTournamentTeamName(leagueTeamUid),
        actions: actions,
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: LeagueOrTournamentTeamDetails(
            leagueOrTournamentTeamUid: leagueTeamUid,
          ),
        ),
      ),
    );
  }
}
