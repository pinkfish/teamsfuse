import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdivison.dart';

class LeagueDivisonScreen extends StatelessWidget {
  final String leagueUid;
  final String leagueDivisonUid;
  final String leagueSeasonUid;

  LeagueDivisonScreen(
      this.leagueUid, this.leagueSeasonUid, this.leagueDivisonUid);

  void _onEditLeague(BuildContext context) {}

  Widget build(BuildContext context) {
    FloatingActionButton fab;
    if (UserDatabaseData.instance.leagueOrTournments.containsKey(leagueUid)) {
      print(
          'league stuff ${UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()}');
      if (UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()) {
        fab = new FloatingActionButton(
          onPressed: () => _onEditLeague(context),
          child: new Icon(Icons.edit),
        );
      }
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new LeagueOrTournamentName(leagueUid),
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: LeagueOrTournamentDivisonDetails(
            leagueOrTournamentUid: leagueUid,
            leagueOrTournamentSeasonUid: leagueSeasonUid,
            leagueOrTournamentDivisonUid: leagueDivisonUid,
          ),
        ),
      ),
    );
  }
}
