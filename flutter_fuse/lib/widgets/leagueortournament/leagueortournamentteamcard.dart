import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'leagueortournamentteamname.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

///
/// Card showing details of a team inside a league/tournament.
///
class LeagueOrTournamentTeamCard extends StatelessWidget {
  final LeagueOrTournamentTeam team;
  final bool admin;

  LeagueOrTournamentTeamCard(this.team, {this.admin = false});

  Widget build(BuildContext context) {
    Widget subtitle;

    subtitle = Text(Messages.of(context).winrecord(team.record));

    return Card(
      child: ListTile(
        onTap: () =>
            Navigator.pushNamed(context, "/League/Team/" + team.uid),
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
        title: LeagueOrTournamentTeamName(team.uid),
        subtitle: subtitle,
      ),
    );
  }
}
