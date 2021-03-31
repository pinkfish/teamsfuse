import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/drawer/fuseddrawer.dart';
import '../../widgets/leagueortournament/leagueimage.dart';

///
/// This shows all the basic stuff about the league/tournaments the person
/// either knows about or is involvoed with.  A mechanism to find tournaments
/// and leagues will be added in here too.
///
class LeagueHomeScreen extends StatelessWidget {
  Widget _buildLeagueOrTournament(BuildContext context, LeagueOrTournament l) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, '/League/Main/${l.uid}'),
        leading: LeagueImage(
          leagueOrTournament: l,
          width: 50.0,
          height: 50.0,
        ),
        title: Text(l.name),
        subtitle: Text(l.shortDescription),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(Messages.of(context).league,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 3.0,
          ),
          BlocBuilder(
            bloc: BlocProvider.of<LeagueOrTournamentBloc>(context),
            builder: (context, state) {
              Iterable<LeagueOrTournament> league = state
                  .leagueOrTournaments.values
                  .where((l) => l.type == LeagueOrTournamentType.League);
              if (league.isEmpty) {
                return Text(Messages.of(context).noLeagues);
              }
              return Column(
                children: league
                    .map((l) => _buildLeagueOrTournament(context, l))
                    .toList(),
              );
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          Divider(),
          SizedBox(
            height: 10.0,
          ),
          Text(Messages.of(context).tournament,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 3.0,
          ),
          BlocBuilder(
            bloc: BlocProvider.of<LeagueOrTournamentBloc>(context),
            builder: (context, state) {
              var tournament = state.leagueOrTournaments.values
                  .where((l) => l.type == LeagueOrTournamentType.Tournament);
              if (tournament.length == 0) {
                return Text(Messages.of(context).noTournaments);
              }
              return Column(
                children: tournament
                    .map((l) => _buildLeagueOrTournament(context, l))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _doAction(BuildContext context, String value) {
    if (value == 'league') {
      Navigator.pushNamed(context, '/League/AddLeague');
    }
    if (value == 'tournament') {
      Navigator.pushNamed(context, '/League/AddTournament');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).leagueTournament),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (str) => _doAction(context, str),
            itemBuilder: (context) {
              return <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: 'league',
                  child: Text(Messages.of(context).addLeague),
                ),
                PopupMenuItem<String>(
                  value: 'tournament',
                  child: Text(Messages.of(context).addTournament),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(Messages.of(context).editButton),
                )
              ];
            },
          ),
        ],
      ),
      drawer: FusedDrawer(DrawerMode.league),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: _buildBody(context),
        ),
      ),
    );
  }
}
