import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../util/communityicons.dart';
import '../util/teamimage.dart';
import 'leagueortournamentteamname.dart';

///
/// Card showing details of a team inside a league/tournament.
///
class LeagueOrTournamentTeamCard extends StatelessWidget {
  LeagueOrTournamentTeamCard(this.leagueUid, this.team,
      {this.admin = false, this.divison});

  final LeagueOrTournamentTeam team;
  final LeagueOrTournamentDivison divison;
  final String leagueUid;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    Widget subtitle;
    if (divison != null) {
      if (team.record.containsKey(divison.uid)) {
        subtitle =
            Text(Messages.of(context).winrecord(team.record[divison.uid]));
      } else {
        WinRecord record = WinRecord();
        subtitle = Text(Messages.of(context).winrecord(record));
      }
    }

    return Card(
      child: ListTile(
        onTap: () => Navigator.pushNamed(
            context,
            "/League/Team/" +
                leagueUid +
                "/" +
                divison.leagueOrTournmentSeasonUid +
                "/" +
                team.uid),
        leading: team.teamUid != null
            ? TeamImage(
                width: 50.0,
                height: 50.0,
                teamUid: team.teamUid,
              )
            : const Icon(
                CommunityIcons.basketball,
                size: 50.0,
              ),
        title: Container(
          alignment: Alignment.topLeft,
          child: LeagueOrTournamentTeamName(
            team.uid,
            textAlign: TextAlign.start,
          ),
        ),
        subtitle: subtitle,
      ),
    );
  }
}
