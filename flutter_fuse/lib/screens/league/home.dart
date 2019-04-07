import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

///
/// This shows all the basic stuff about the league/tournaments the person
/// either knows about or is involvoed with.  A mechanism to find tournaments
/// and leagues will be added in here too.
///
class LeagueHomeScreen extends StatelessWidget {
  Widget _buildLeagueOrTournament(BuildContext context, LeagueOrTournament l) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, "/League/Main/" + l.uid),
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
                  .subhead
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 3.0,
          ),
          BlocBuilder<LeagueOrTournamentEvent, LeagueOrTournamentState>(
            bloc: BlocProvider.of<LeagueOrTournamentBloc>(context),
            builder: (BuildContext context, LeagueOrTournamentState state) {
              Iterable<LeagueOrTournament> league = state
                  .leagueOrTournaments.values
                  .where((LeagueOrTournament l) =>
                      l.type == LeagueOrTournamentType.League);
              if (league.length == 0) {
                return Text(Messages.of(context).noleagues);
              }
              return Column(
                children: league
                    .map((LeagueOrTournament l) =>
                        _buildLeagueOrTournament(context, l))
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
                  .subhead
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 3.0,
          ),
          BlocBuilder<LeagueOrTournamentEvent, LeagueOrTournamentState>(
            bloc: BlocProvider.of<LeagueOrTournamentBloc>(context),
            builder: (BuildContext context, LeagueOrTournamentState state) {
              Iterable<LeagueOrTournament> tournament = state
                  .leagueOrTournaments.values
                  .where((LeagueOrTournament l) =>
                      l.type == LeagueOrTournamentType.Tournament);
              if (tournament.length == 0) {
                return Text(Messages.of(context).notournaments);
              }
              return Column(
                children: tournament
                    .map((LeagueOrTournament l) =>
                        _buildLeagueOrTournament(context, l))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _doAction(BuildContext context, String value) {
    if (value == "league") {
      Navigator.pushNamed(context, "/League/AddLeague");
    }
    if (value == "tournament") {
      Navigator.pushNamed(context, "/League/AddTournament");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(Messages.of(context).leaguetournament),
        actions: <Widget>[
          new PopupMenuButton<String>(
            onSelected: (String str) => _doAction(context, str),
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                new PopupMenuItem<String>(
                  value: "league",
                  child: new Text(Messages.of(context).addleague),
                ),
                new PopupMenuItem<String>(
                  value: "tournament",
                  child: new Text(Messages.of(context).addtournament),
                ),
                new PopupMenuItem<String>(
                  value: 'edit',
                  child: Text(Messages.of(context).editbuttontext),
                )
              ];
            },
          ),
        ],
      ),
      drawer: new FusedDrawer(DrawerMode.league),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: _buildBody(context),
        ),
      ),
    );
  }
}
