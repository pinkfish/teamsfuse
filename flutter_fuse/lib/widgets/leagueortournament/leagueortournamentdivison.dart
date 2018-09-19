import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'leagueortournamentteamcard.dart';
import 'package:flutter_fuse/widgets/games/gamesharedcard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'addteamdialog.dart';
import 'package:timezone/timezone.dart';
import 'package:intl/intl.dart';

///
/// The details section to display on a page in the app about the
/// divison of the league.
///
class LeagueOrTournamentDivisonDetails extends StatefulWidget {
  final String leagueOrTournamentUid;
  final String leagueOrTournamentSeasonUid;
  final String leagueOrTournamentDivisonUid;

  LeagueOrTournamentDivisonDetails(
      {@required this.leagueOrTournamentUid,
      @required this.leagueOrTournamentSeasonUid,
      @required this.leagueOrTournamentDivisonUid});

  @override
  State createState() {
    return new _LeagueOrTournamentDivisonDetailsState();
  }
}

class _LeagueOrTournamentDivisonDetailsState
    extends State<LeagueOrTournamentDivisonDetails> {
  bool _gameExpanded = true;
  bool _teamExpanded = false;
  LeagueOrTournament leagueOrTournament;
  LeagueOrTournamentSeason leagueOrTournmentSeason;
  LeagueOrTournamentDivison leagueOrTournmentDivison;

  static DateFormat monthFormat = new DateFormat(DateFormat.ABBR_MONTH);
  static DateFormat dayOfWeekFormat = new DateFormat(DateFormat.ABBR_WEEKDAY);
  static DateFormat dayOfMonthFormat =
      new DateFormat(DateFormat.ABBR_MONTH_DAY);
  static const double widthFirst = 40.0;
  static const double inset = 5.0;

  void initState() {
    super.initState();
    leagueOrTournament = UserDatabaseData
        .instance.leagueOrTournments[widget.leagueOrTournamentUid];
    leagueOrTournmentSeason = leagueOrTournament.cacheSeasons.firstWhere(
        (LeagueOrTournamentSeason s) =>
            s.uid == widget.leagueOrTournamentSeasonUid);
    leagueOrTournmentDivison = leagueOrTournmentSeason.cacheDivisions
        .firstWhere((LeagueOrTournamentDivison s) =>
            s.uid == widget.leagueOrTournamentDivisonUid);
  }

  void _addGame(String uid) {
    Navigator.pushNamed(
        context, "/AddSharedGame/" + leagueOrTournament.uid + "/" + uid);
  }

  Widget _buildGamesList() {
    if (!_gameExpanded) {
      return Text("closed");
    }
    return StreamBuilder(
      stream: leagueOrTournmentDivison.gameStream,
      builder:
          (BuildContext contex, AsyncSnapshot<Iterable<GameSharedData>> snap) {
        Iterable<GameSharedData> games = leagueOrTournmentDivison.cachedGames;
        if (snap.hasData) {
          games = snap.data;
        }
        if (games == null) {
          return Text(Messages.of(context).loading);
        }
        if (games.length == 0) {
          if (leagueOrTournament.isAdmin()) {
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
                      onPressed: () => _addGame(leagueOrTournmentDivison.uid),
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
        List<Widget> displayEvents = [];
        DateTime day = new DateTime(1970);
        final Size screenSize = MediaQuery.of(context).size;
        double widthSecond = screenSize.width - widthFirst - inset - 20.0;

        for (GameSharedData g in sortedGames) {
          displayEvents.add(GameSharedCard(g));
          if (day.month != g.tzTime.month || day.day != g.tzTime.day) {
            children.add(new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  constraints: new BoxConstraints.tightFor(width: widthFirst),
                  margin: new EdgeInsets.only(top: 5.0, left: inset),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text(
                        dayOfWeekFormat.format(day),
                        style: style,
                      ),
                      new Text(
                        dayOfMonthFormat.format(day),
                        style: style.copyWith(fontSize: 10.0),
                      ),
                    ],
                  ),
                ),
                new Container(
                  constraints: new BoxConstraints.tightFor(width: widthSecond),
                  margin: new EdgeInsets.only(top: 10.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: displayEvents,
                  ),
                ),
              ],
            ));
            day = new DateTime(g.tzTime.year, g.tzTime.month, g.tzTime.day);
            displayEvents = [];
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

  void _addTeam() {
    AddTeamDialog.showTeamDialog(context, widget.leagueOrTournamentDivisonUid);
  }

  Widget build(BuildContext context) {
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.
    assert(leagueOrTournmentSeason != null);
    assert(leagueOrTournmentDivison != null);
    assert(leagueOrTournament != null);

    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            leading: LeagueImage(
              leagueOrTournament: leagueOrTournament,
              width: 50.0,
              height: 50.0,
            ),
            title: Text(
              leagueOrTournament.name,
              style: Theme.of(context).textTheme.headline,
            ),
            subtitle: Text(
              "${leagueOrTournmentSeason.name} ${leagueOrTournmentDivison.name}",
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          StreamBuilder(
              stream: leagueOrTournmentDivison.teamStream,
              builder: (BuildContext context,
                  AsyncSnapshot<Iterable<LeagueOrTournamentTeam>> snap) {
                Iterable<LeagueOrTournamentTeam> teams =
                    leagueOrTournmentDivison.cachedTeams;
                if (snap.hasData) {
                  teams = snap.data;
                }
                if (!snap.hasData && teams == null) {
                  return Container(
                    margin: EdgeInsets.all(5.0),
                    child: Text(Messages.of(context).loading),
                  );
                }
                if (teams.length == 0) {
                  if (leagueOrTournament.isAdmin()) {
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(Messages.of(context).noteams),
                          FlatButton(
                            onPressed: () => _addTeam(),
                            child: Text(
                              Messages.of(context).addteam,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context).accentColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(Messages.of(context).noteams),
                    );
                  }
                }
                List<Widget> children = teams
                    .map<Widget>((LeagueOrTournamentTeam team) =>
                        LeagueOrTournamentTeamCard(
                          team,
                          admin: leagueOrTournament.isAdmin(),
                        ))
                    .toList();
                if (leagueOrTournament.isAdmin()) {
                  children.add(new SizedBox(height: 10.0));
                  children.add(
                    FlatButton(
                      onPressed: () => _addTeam(),
                      child: Text(
                        Messages.of(context).addteam,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Theme.of(context).accentColor),
                      ),
                    ),
                  );
                }
                return ExpansionPanelList(
                    expansionCallback: (int pos, bool opened) {
                      setState(() {
                        _teamExpanded = !opened;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        isExpanded: _teamExpanded,
                        headerBuilder: (BuildContext context, bool opened) {
                          return Container(
                            margin: EdgeInsets.only(left: 5.0, right: 5.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                Messages.of(context).teamnumbers(teams.length)),
                          );
                        },
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: children,
                        ),
                      )
                    ]);
              }),
           _buildGamesList(),

        ],
      ),
    );
  }
}
