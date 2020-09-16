import 'package:flutter/material.dart';

import '../../services/messages.dart';
import '../../widgets/leagueortournament/leagueortournamentdivisongames.dart';
import '../../widgets/leagueortournament/leagueortournamentdivisonteams.dart';
import '../../widgets/leagueortournament/leagueortournamentname.dart';

///
/// Shows the league divison on the screen.
///
class LeagueDivisonScreen extends StatefulWidget {
  /// Constructor.
  LeagueDivisonScreen(
      this.leagueUid, this.leagueSeasonUid, this.leagueDivisonUid);

  /// The league to lookup the division for and display.
  final String leagueUid;

  /// The divison in the league to lookup.
  final String leagueDivisonUid;

  /// The season in the league to lookup.
  final String leagueSeasonUid;

  @override
  State createState() {
    return _LeagueDivisonScreenState();
  }
}

class _LeagueDivisonScreenState extends State<LeagueDivisonScreen> {
  int _tabIndex = 0;

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return LeagueOrTournamentDivisonDetails(
          leagueOrTournamentUid: widget.leagueUid,
          leagueOrTournamentSeasonUid: widget.leagueSeasonUid,
          leagueOrTournamentDivisonUid: widget.leagueDivisonUid,
        );
      case 1:
        return LeagueOrTournamentDivisonTeamDetails(
          leagueOrTournamentUid: widget.leagueUid,
          leagueOrTournamentSeasonUid: widget.leagueSeasonUid,
          leagueOrTournamentDivisonUid: widget.leagueDivisonUid,
        );
      case 2:
        return Text(Messages.of(context).unknown);
    }
    return SizedBox(
      width: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton fab;
    var actions = <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: LeagueOrTournamentName(
          widget.leagueUid,
          leagueOrTournamentDivisonUid: widget.leagueDivisonUid,
        ),
        actions: actions,
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _tabIndex = index;
            });
          },
          currentIndex: _tabIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.games),
              title: Text(Messages.of(context).games),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text(Messages.of(context).teams),
            )
          ]),
      body: _buildBody(),
    );
  }
}
