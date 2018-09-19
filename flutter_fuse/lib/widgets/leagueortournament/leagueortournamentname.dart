import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class LeagueOrTournamentName extends StatelessWidget {
  final String leagueOrTournamentUid;
  final TextStyle style;
  final TextAlign textAlign;

  LeagueOrTournamentName(this.leagueOrTournamentUid, {this.style, this.textAlign});
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: UserDatabaseData.instance
            .getLegueOrTournament(leagueOrTournamentUid),
        builder:
            (BuildContext context, AsyncSnapshot<LeagueOrTournament> data) {
          if (data.hasData) {
            return Text(
              data.data.name,
              style: style,
              textAlign: textAlign,
            );
          }
          return Text(
            Messages.of(context).loading,
            style: style,
            textAlign: textAlign,
          );
        });
  }
}
