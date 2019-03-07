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
  final String leagueOrTournamentDivisonUid;

  LeagueOrTournamentName(this.leagueOrTournamentUid,
      {this.leagueOrTournamentDivisonUid, this.style, this.textAlign});

  Widget _nameFuture() {
    return new FutureBuilder<LeagueOrTournament>(
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
              overflow: TextOverflow.ellipsis,
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

  Widget _divisionFuture() {
    return new FutureBuilder<LeagueOrTournamentDivison>(
        future: UserDatabaseData.instance.updateModel
            .getLeagueDivisionData(leagueOrTournamentDivisonUid),
        builder: (BuildContext context,
            AsyncSnapshot<LeagueOrTournamentDivison> data) {
          Widget inner;
          print('Loaded $leagueOrTournamentDivisonUid');

          if (data.hasData) {
            inner = Text(
              data.data.name,
              style: style,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            inner = Text(
              "",
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

  @override
  Widget build(BuildContext context) {
    if (leagueOrTournamentDivisonUid == null) {
      return  _nameFuture();
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _divisionFuture(),
        SizedBox(
          width: 15.0,
        ),
        Flexible(child: _nameFuture()),
      ],
    );
  }
}
