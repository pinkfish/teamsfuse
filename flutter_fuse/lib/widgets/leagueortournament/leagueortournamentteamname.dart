import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class LeagueOrTournamentTeamName extends StatelessWidget {
  final String leagueOrTournmentTeamUid;
  final TextStyle style;

  LeagueOrTournamentTeamName(this.leagueOrTournmentTeamUid, {this.style});
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: UserDatabaseData.instance.updateModel
          .getLeagueTeamData(leagueOrTournmentTeamUid),
      builder:
          (BuildContext context, AsyncSnapshot<LeagueOrTournamentTeam> data) {
        if (data.hasData) {
          if (data.data == null) {
            return Text(Messages.of(context).unknown, style: style);
          }
          return Text(
            data.data.name,
            style: style,
          );
        }
        return Text(
          Messages.of(context).loading,
          style: style,
        );
      },
    );
  }
}
