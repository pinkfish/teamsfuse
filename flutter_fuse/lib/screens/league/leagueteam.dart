import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteam.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';

class LeagueTeamScreen extends StatelessWidget {
  final String leagueTeamUid;

  LeagueTeamScreen(this.leagueTeamUid);

  Widget build(BuildContext context) {
    FloatingActionButton fab;

    return new Scaffold(
      appBar: new AppBar(
        title: new LeagueOrTournamentTeamName(leagueTeamUid),
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
