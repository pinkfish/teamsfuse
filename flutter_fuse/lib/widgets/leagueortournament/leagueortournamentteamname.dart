import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class LeagueOrTournamentTeamName extends StatelessWidget {
  LeagueOrTournamentTeamName(this.leagueOrTournmentTeamUid,
      {this.style, this.textAlign, this.overflow});

  final String leagueOrTournmentTeamUid;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<LeagueOrTournamentTeam>(
      future: UserDatabaseData.instance.updateModel
          .getLeagueTeamData(leagueOrTournmentTeamUid),
      builder:
          (BuildContext context, AsyncSnapshot<LeagueOrTournamentTeam> data) {
        Widget inner;
        if (data.hasData) {
          if (data.data == null) {
            inner = Text(
              Messages.of(context).unknown,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else {
            inner = Text(
              data.data.name,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          }
        } else {
          inner = Text(
            Messages.of(context).loading,
            style: style,
            textAlign: textAlign,
            overflow: overflow,
          );
        }
        return AnimatedSwitcher(
            child: inner, duration: Duration(milliseconds: 300));
      },
    );
  }
}
