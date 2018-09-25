import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamesharedcard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'dart:async';
import 'addinvitetoteamdialog.dart';

///
/// The details to display in the app about the team in a league or
/// tournament.
///
class LeagueOrTournamentTeamDetails extends StatefulWidget {
  final String leagueOrTournamentTeamUid;

  LeagueOrTournamentTeamDetails({@required this.leagueOrTournamentTeamUid});

  @override
  State createState() {
    return new _LeagueOrTournamentTeamDetailsState();
  }
}

class _LeagueOrTournamentTeamDetailsState
    extends State<LeagueOrTournamentTeamDetails> {
  LeagueOrTournament leagueOrTournament;
  LeagueOrTournamentSeason leagueOrTournmentSeason;
  LeagueOrTournamentDivison leagueOrTournmentDivison;
  LeagueOrTournamentTeam leagueOrTournamentTeam;
  StreamSubscription<LeagueOrTournamentTeam> _sub;

  void initState() {
    super.initState();
    // Start trying to load the team.
  }

  ///
  /// Load the details but only do so once.
  ///
  Future<LeagueOrTournamentSeason> _loadDetails() async {
    if (leagueOrTournamentTeam == null) {
      leagueOrTournamentTeam = await UserDatabaseData.instance.updateModel
          .getLeagueTeamData(widget.leagueOrTournamentTeamUid);
    }
    // Update the UX.
    setState(() => true);

    if (leagueOrTournamentTeam != null && leagueOrTournmentDivison == null) {
      leagueOrTournamentTeam.loadInvites();
      _sub = leagueOrTournamentTeam.thisTeamStream
          .listen((LeagueOrTournamentTeam t) {
        setState(() {});
      });
      // load a bit more stuff.
      leagueOrTournmentDivison = await UserDatabaseData.instance.updateModel
          .getLeagueDivisionData(
              leagueOrTournamentTeam.leagueOrTournamentDivisonUid);
      setState(() => true);
    }

    if (leagueOrTournmentDivison != null && leagueOrTournmentSeason == null) {
      // Load the rest.
      leagueOrTournmentSeason = await UserDatabaseData.instance.updateModel
          .getLeagueSeasonData(
              leagueOrTournmentDivison.leagueOrTournmentSeasonUid);
      setState(() => true);
    }
    if (leagueOrTournmentSeason != null && leagueOrTournament == null) {
      leagueOrTournament = await UserDatabaseData.instance.updateModel
          .getLeagueData(leagueOrTournmentSeason.leagueOrTournmentUid);
    }
    return leagueOrTournmentSeason;
  }

  void dispose() {
    super.dispose();
    _sub?.cancel();
  }

  String _seasonName() {
    if (leagueOrTournmentSeason != null) {
      return leagueOrTournmentSeason.name;
    }
    return Messages.of(context).loading;
  }

  String _divisonName() {
    if (leagueOrTournmentDivison != null) {
      return leagueOrTournmentDivison.name;
    }
    return Messages.of(context).loading;
  }

  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.

    return Container(
      margin: EdgeInsets.all(5.0),
      child: FutureBuilder(
        future: _loadDetails(),
        builder: (BuildContext context,
            AsyncSnapshot<LeagueOrTournamentSeason> snap) {
          if (!snap.hasData) {
            return Center(child: Text(Messages.of(context).loading));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              LeagueImage(
                leagueOrTournament: leagueOrTournament,
                width: (screenSize.width < 500)
                    ? 120.0
                    : (screenSize.width / 4) + 12.0,
                height: screenSize.height / 4 + 20,
              ),
              Text(
                leagueOrTournament.name,
                style: Theme.of(context).textTheme.headline,
              ),
              Text("${_seasonName()}",
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(fontWeight: FontWeight.bold)),
              Text("${_divisonName()}",
                  style: Theme.of(context).textTheme.subhead),
              StreamBuilder(
                stream: leagueOrTournmentDivison != null
                    ? leagueOrTournmentDivison.gameStream
                    : null,
                builder: (BuildContext context,
                    AsyncSnapshot<Iterable<GameSharedData>> snap) {
                  Iterable<GameSharedData> games =
                      leagueOrTournmentDivison.cachedGames;
                  if (snap.hasData) {
                    games = snap.data;
                  }
                  if (games == null) {
                    return Text(Messages.of(context).loading);
                  }
                  List<GameSharedData> sortedGames = games
                      .where((GameSharedData g) =>
                          g.officialResults.homeTeamLeagueUid ==
                              widget.leagueOrTournamentTeamUid ||
                          g.officialResults.awayTeamLeagueUid ==
                              widget.leagueOrTournamentTeamUid)
                      .toList();
                  if (sortedGames.length == 0) {
                    return Text(Messages.of(context).nogames);
                  }

                  sortedGames.sort((GameSharedData g1, GameSharedData g2) =>
                      (g1.time - g2.time).toInt());
                  List<Widget> children = sortedGames
                      .map<Widget>((GameSharedData g) => GameSharedCard(g))
                      .toList();
                  if (leagueOrTournamentTeam.teamUid == null &&
                      leagueOrTournament.isAdmin()) {
                    children.add(new ExpansionTile(
                      title: Text(
                        Messages.of(context).invitedpeople(
                            leagueOrTournamentTeam.cachedInvites?.length ?? 0),
                      ),
                      initiallyExpanded: false,
                      children: leagueOrTournamentTeam.cachedInvites
                          .map((InviteToLeagueTeam invite) {
                        return ListTile(
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                          ),
                          title: Text(
                            invite.email,
                          ),
                        );
                      }).toList(),
                    ));
                    children.add(
                      Align(
                        alignment: Alignment.topLeft,
                        child: ButtonBar(
                          children: [
                            FlatButton(
                              onPressed: () =>
                                  AddInviteToTeamDialog.showAddTeamInviteDialog(
                                      context,
                                      leagueOrTournament,
                                      leagueOrTournamentTeam),
                              child: Text(
                                Messages.of(context).addteamadmin,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        color: Theme.of(context).accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: children,
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
