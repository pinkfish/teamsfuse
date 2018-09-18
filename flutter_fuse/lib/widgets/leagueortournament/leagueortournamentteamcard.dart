import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'leagueortournamentteamname.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';

///
/// Card showing details of a team inside a league/tournament.
///
class LeagueOrTournamentTeamCard extends StatelessWidget {
  final LeagueOrTournamentTeam team;

  LeagueOrTournamentTeamCard(this.team);

  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () =>
            Navigator.pushNamed(context, "/LeagueTeam/" + team.teamUid),
        leading: team.teamUid != null
            ? TeamImage(
                width: 50.0,
                height: 50.0,
                teamUid: team.teamUid,
              )
            : const Icon(
                Icons.device_unknown,
                size: 50.0,
              ),
        title: LeagueOrTournamentTeamName(team.uid),
        subtitle: Text(Messages.of(context).winrecord(team.record)),
      ),
    );
  }
}
