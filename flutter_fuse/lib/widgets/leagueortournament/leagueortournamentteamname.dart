import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class LeagueOrTournamentTeamName extends StatelessWidget {
  final String leagueOrTournmentTeamUid;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  LeagueOrTournamentTeamName(this.leagueOrTournmentTeamUid, {this.style, this.textAlign, this.overflow});
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: UserDatabaseData.instance.updateModel
          .getLeagueTeamData(leagueOrTournmentTeamUid),
      builder:
          (BuildContext context, AsyncSnapshot<LeagueOrTournamentTeam> data) {
        if (data.hasData) {
          if (data.data == null) {
            return Text(Messages.of(context).unknown, style: style, textAlign: textAlign,overflow: overflow,);
          }
          return Text(
            data.data.name,
            style: style,
            textAlign: textAlign,
            overflow: overflow,
          );
        }
        return Text(
          Messages.of(context).loading,
          style: style,
          textAlign: textAlign,
          overflow: overflow,
        );
      },
    );
  }
}
