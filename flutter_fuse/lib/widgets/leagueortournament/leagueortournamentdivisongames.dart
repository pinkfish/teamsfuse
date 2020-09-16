import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/leagueteampicker.dart';
import 'package:flutter_fuse/widgets/games/gamesharedcard.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonDetails extends StatefulWidget {
  LeagueOrTournamentDivisonDetails(
      {@required this.leagueOrTournamentUid,
      @required this.leagueOrTournamentSeasonUid,
      @required this.leagueOrTournamentDivisonUid});

  final String leagueOrTournamentUid;
  final String leagueOrTournamentSeasonUid;
  final String leagueOrTournamentDivisonUid;

  @override
  State createState() {
    return _LeagueOrTournamentDivisonDetailsState();
  }
}

class _LeagueOrTournamentDivisonDetailsState
    extends State<LeagueOrTournamentDivisonDetails> {
  String _currentTeamConstraint = TournamentOrLeagueTeamPicker.all;

  static DateFormat monthFormat = DateFormat(DateFormat.ABBR_MONTH);
  static DateFormat dayOfWeekFormat = DateFormat(DateFormat.ABBR_WEEKDAY);
  static DateFormat dayOfMonthFormat = DateFormat(DateFormat.ABBR_MONTH_DAY);
  static const double widthFirst = 40.0;
  static const double inset = 5.0;

  @override
  void initState() {
    super.initState();
  }

  void _addGame(String uid) {
    Navigator.pushNamed(
        context, "/AddSharedGame/" + widget.leagueOrTournamentUid + "/" + uid);
  }

  Widget _buildGamesList(SingleLeagueOrTournamentState leagueState,
      SingleLeagueOrTournamentDivisonState divisonState) {
    SingleLeagueOrTournamentDivisonBloc bloc =
        BlocProvider.of<SingleLeagueOrTournamentDivisonBloc>(context);
    return BlocBuilder(
      cubit: bloc,
      builder: (BuildContext context,
          SingleLeagueOrTournamentDivisonState gamesState) {
        if (!gamesState.loadedGames) {
          return Text(Messages.of(context).loading);
        }
        BlocProvider.of<SingleLeagueOrTournamentDivisonBloc>(context)
            .add(SingleLeagueOrTournamentDivisonLoadGames());
        // Filter only the ones we want.
        Iterable<GameSharedData> games = gamesState.games.values;
        if (_currentTeamConstraint != TournamentOrLeagueTeamPicker.all) {
          games = games.where((GameSharedData g) =>
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
                      onPressed: () => _addGame(bloc.leagueDivisonUid),
                      child: Text(Messages.of(context).addgame,
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Theme.of(context).accentColor)),
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

        List<GameSharedData> sortedGames = games.toList();
        sortedGames.sort((GameSharedData g1, GameSharedData g2) =>
            (g1.time - g2.time).toInt());

        List<Widget> children = <Widget>[];

        TextStyle style = Theme.of(context).textTheme.subhead.copyWith(
              fontWeight: FontWeight.w300,
            );
        List<Widget> displayEvents = <Widget>[];
        DateTime day = DateTime(1970);
        final Size screenSize = MediaQuery.of(context).size;
        double widthSecond = screenSize.width - widthFirst - inset - 20.0;

        for (GameSharedData g in sortedGames) {
          if (displayEvents.length == 0) {
            // The day is the current game day.
            day = g.tzTime;
          }
          displayEvents.add(GameSharedCard(g));
          if (day.month != g.tzTime.month || day.day != g.tzTime.day) {
            children.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints.tightFor(width: widthFirst),
                  margin: EdgeInsets.only(top: 5.0, left: inset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        dayOfWeekFormat.format(day),
                        style: style,
                      ),
                      Text(
                        dayOfMonthFormat.format(day),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.
    return SingleLeagueOrTournamentProvider(
      leagueUid: widget.leagueOrTournamentUid,
      builder:
          (BuildContext context, SingleLeagueOrTournamentBloc leagueBloc) =>
              SingleLeagueOrTournamentSeasonProvider(
        leagueSeasonUid: widget.leagueOrTournamentSeasonUid,
        builder: (BuildContext context,
                SingleLeagueOrTournamentSeasonBloc seasonBloc) =>
            SingleLeagueOrTournamentDivisonProvider(
                leagueDivisonUid: widget.leagueOrTournamentDivisonUid,
                singleLeagueOrTournamentSeasonBloc: seasonBloc,
                builder: (BuildContext context,
                    SingleLeagueOrTournamentDivisonBloc divisonBloc) {
                  divisonBloc.add(SingleLeagueOrTournamentDivisonLoadGames());
                  return BlocBuilder(
                    cubit: leagueBloc,
                    builder: (BuildContext context,
                        SingleLeagueOrTournamentState leagueState) {
                      if (leagueState is SingleLeagueOrTournamentDeleted) {
                        return Text(Messages.of(context).loading);
                      }

                      return BlocBuilder(
                        cubit: seasonBloc,
                        builder: (BuildContext context,
                                SingleLeagueOrTournamentSeasonState
                                    seasonState) =>
                            BlocBuilder(
                                cubit: divisonBloc,
                                builder: (BuildContext context,
                                    SingleLeagueOrTournamentDivisonState
                                        divisonState) {
                                  return Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        ListTile(
                                          leading: LeagueImage(
                                            leagueOrTournamentUid:
                                                widget.leagueOrTournamentUid,
                                            width: 50.0,
                                            height: 50.0,
                                          ),
                                          title: Text(
                                            leagueState.league.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline,
                                          ),
                                          subtitle: Text(
                                            "${seasonState.season.name} ${divisonState.divison.name}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subhead,
                                          ),
                                        ),
                                        TournamentOrLeagueTeamPicker(
                                          leagueOrTournamentDivisonBloc:
                                              divisonBloc,
                                          initialTeamUid:
                                              _currentTeamConstraint,
                                          includeAll: true,
                                          onChanged: (String str) => setState(
                                              () =>
                                                  _currentTeamConstraint = str),
                                        ),
                                        Expanded(
                                          child: Scrollbar(
                                            child: SingleChildScrollView(
                                              child: _buildGamesList(
                                                  leagueState, divisonState),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                      );
                    },
                  );
                }),
      ),
    );
  }
}
