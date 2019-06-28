import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdivisongames.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdivisonteams.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';

class LeagueDivisonScreen extends StatefulWidget {
  LeagueDivisonScreen(
      this.leagueUid, this.leagueSeasonUid, this.leagueDivisonUid);

  final String leagueUid;
  final String leagueDivisonUid;
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
    List<Widget> actions = <Widget>[];

    return new Scaffold(
      appBar: new AppBar(
        title: new LeagueOrTournamentName(
          widget.leagueUid,
          leagueOrTournamentDivisonUid: widget.leagueDivisonUid,
        ),
        actions: actions,
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
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
