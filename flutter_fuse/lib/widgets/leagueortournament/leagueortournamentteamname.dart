import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class LeagueOrTournamentTeamName extends StatelessWidget {
  final String leagueOrTournmentTeamUid;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  LeagueOrTournamentTeamName(this.leagueOrTournmentTeamUid,
      {this.style, this.textAlign, this.overflow});

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
