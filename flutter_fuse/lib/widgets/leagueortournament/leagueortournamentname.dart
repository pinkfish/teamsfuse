import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

///
/// Puts the name of the league or tournament in the UX
///
class LeagueOrTournamentName extends StatelessWidget {
  final String leagueOrTournamentUid;
  final TextStyle style;
  final TextAlign textAlign;

  LeagueOrTournamentName(this.leagueOrTournamentUid,
      {this.style, this.textAlign});
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: UserDatabaseData.instance
            .getLegueOrTournament(leagueOrTournamentUid),
        builder:
            (BuildContext context, AsyncSnapshot<LeagueOrTournament> data) {
          Widget inner;
          if (data.hasData) {
            inner = Text(
              data.data.name,
              style: style,
              textAlign: textAlign,
            );
          } else {
            inner = Text(
              Messages.of(context).loading,
              style: style,
              textAlign: textAlign,
            );
          }
          return AnimatedSwitcher(
            child: inner,
            duration: Duration(milliseconds: 300),
          );
        });
  }
}
