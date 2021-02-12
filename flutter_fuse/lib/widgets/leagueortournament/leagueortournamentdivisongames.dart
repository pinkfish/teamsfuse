import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentseasonname.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../form/leagueteampicker.dart';
import '../games/gamesharedcard.dart';
import 'leagueimage.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonDetails extends StatefulWidget {
  /// Constructor.
  LeagueOrTournamentDivisonDetails(
      {@required this.leagueOrTournamentDivisonUid});

  /// The league or tournament divison to show the details of.
  final String leagueOrTournamentDivisonUid;

  @override
  State createState() {
    return _LeagueOrTournamentDivisonDetailsState();
  }
}

class _LeagueOrTournamentDivisonDetailsState
    extends State<LeagueOrTournamentDivisonDetails> {
  String _currentTeamConstraint = TournamentOrLeagueTeamPicker.all;

  static DateFormat _dayOfWeekFormat = DateFormat(DateFormat.ABBR_WEEKDAY);
  static DateFormat _dayOfMonthFormat = DateFormat(DateFormat.ABBR_MONTH_DAY);
  static const double _widthFirst = 40.0;
  static const double _inset = 5.0;

  @override
  void initState() {
    super.initState();
  }

  void _addGame(String uid, String leagueOrTournamentUid) {
    Navigator.pushNamed(context, "/AddSharedGame/$leagueOrTournamentUid/$uid");
  }

  Widget _buildGamesList(SingleLeagueOrTournamentDivisonState divisonState,
      SingleLeagueOrTournamentState leagueState) {
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: divisonState.divison.uid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, SingleLeagueOrTournamentDivisonState divisonState) {
          if (!divisonState.loadedGames) {
            bloc.add(SingleLeagueOrTournamentDivisonLoadGames());
            return Text(Messages.of(context).loading);
          }
          // Filter only the ones we want.
          var games = divisonState.games.values;
          if (_currentTeamConstraint != TournamentOrLeagueTeamPicker.all) {
            games = games.where((g) =>
                g.officialResult.homeTeamLeagueUid == _currentTeamConstraint ||
                g.officialResult.awayTeamLeagueUid == _currentTeamConstraint);
          }
          if (games.length == 0) {
            if (leagueState.league.isAdmin()) {
              return Container(
                margin: EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(Messages.of(context).nogames),
                    Align(
                      alignment: Alignment.topLeft,
                      child: FlatButton(
                        onPressed: () => _addGame(bloc.leagueDivisonUid,
                            divisonState.divison.leagueOrTournamentUid),
                        child: Text(Messages.of(context).addgamebutton,
                            style: Theme.of(context).textTheme.button.copyWith(
                                color: Theme.of(context).accentColor)),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                margin: EdgeInsets.all(5.0),
                child: Text(Messages.of(context).nogames),
              );
            }
          }

          var sortedGames = games.toList();
          sortedGames.sort((g1, g2) => (g1.time.compareTo(g2.time)).toInt());

          var children = <Widget>[];

          var style = Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.w300,
              );
          var displayEvents = <Widget>[];
          var day = DateTime(1970);
          var screenSize = MediaQuery.of(context).size;
          var widthSecond = screenSize.width - _widthFirst - _inset - 20.0;

          for (var g in sortedGames) {
            if (children.length == 0) {
              // The day is the current game day.
              day = g.tzTime;
            }
            children.add(GameSharedCard(g));
            if (day.month != g.tzTime.month || day.day != g.tzTime.day) {
              children.add(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints.tightFor(width: _widthFirst),
                    margin: EdgeInsets.only(top: 5.0, left: _inset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _dayOfWeekFormat.format(day),
                          style: style,
                        ),
                        Text(
                          _dayOfMonthFormat.format(day),
                          style: style.copyWith(fontSize: 10.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints.tightFor(width: widthSecond),
                    margin: EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: displayEvents,
                    ),
                  ),
                ],
              ));
              day = DateTime(g.tzTime.year, g.tzTime.month, g.tzTime.day);
              displayEvents = <Widget>[];
            }
          }

          return Container(
            margin: EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: widget.leagueOrTournamentDivisonUid,
      builder: (context, divisonBloc) => BlocBuilder(
        cubit: divisonBloc,
        builder: (context, SingleLeagueOrTournamentDivisonState divisonState) {
          if (divisonState is SingleLeagueOrTournamentDivisonUninitialized ||
              divisonState is SingleLeagueOrTournamentDivisonDeleted) {
            return Text(Messages.of(context).loading);
          }
          if (!divisonState.loadedGames) {
            divisonBloc.add(SingleLeagueOrTournamentDivisonLoadGames());
          }

          return Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: LeagueImage(
                    leagueOrTournamentUid:
                        divisonState.divison.leagueOrTournamentUid,
                    width: 50.0,
                    height: 50.0,
                  ),
                  title: LeagueOrTournamentName(
                    divisonState.divison.leagueOrTournamentUid,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  subtitle: Row(
                    children: [
                      LeagueOrTournamentSeasonName(
                          leagueOrTournmentSeasonUid:
                              divisonState.divison.leagueOrTournmentSeasonUid),
                      Text(
                        "${divisonState.divison.name}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ),
                TournamentOrLeagueTeamPicker(
                  leagueOrTournamentDivisonBloc: divisonBloc,
                  initialTeamUid: _currentTeamConstraint,
                  includeAll: true,
                  onChanged: (str) =>
                      setState(() => _currentTeamConstraint = str),
                ),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: SingleLeagueOrTournamentProvider(
                        leagueUid: divisonState.divison.leagueOrTournamentUid,
                        builder: (context, leagueBloc) => BlocBuilder(
                          cubit: leagueBloc,
                          builder: (context, leagueState) =>
                              _buildGamesList(divisonState, leagueState),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
