import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class LeagueOrTournamentName extends StatelessWidget {
  final String leagueOrTournamentUid;
  final TextStyle style;

  LeagueOrTournamentName(this.leagueOrTournamentUid, {this.style});
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
            );
          }
          return Text(
            Messages.of(context).loading,
            style: style,
          );
        });
  }
}
