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
  /// Constructor.
  LeagueOrTournamentTeamCard(this.leagueUid, this.team,
      {this.admin = false, this.divison});

  /// The team in the league to display
  final LeagueOrTournamentTeam team;

  /// The divison in the league to display.
  final LeagueOrTournamentDivison divison;

  /// The leagueUid to display
  final String leagueUid;

  /// If we are an admin in this team
  final bool admin;

  @override
  Widget build(BuildContext context) {
    Widget subtitle;
    if (divison != null) {
      if (team.record.containsKey(divison.uid)) {
        subtitle =
            Text(Messages.of(context).winrecord(team.record[divison.uid]));
      } else {
        var record = WinRecord();
        subtitle = Text(Messages.of(context).winrecord(record));
      }
    }

    return Card(
      child: ListTile(
        onTap: () => Navigator.pushNamed(context,
            "/League/Team/$leagueUid/${divison.leagueOrTournmentSeasonUid}/${team.uid}"),
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
