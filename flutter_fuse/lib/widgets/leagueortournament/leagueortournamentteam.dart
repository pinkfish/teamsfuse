import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamesharedcard.dart';
import 'package:flutter/foundation.dart';
import 'leagueortournamentteamname.dart';

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
  bool _tileExpanded;
  Game leagueOrTournament;
  LeagueOrTournamentSeason leagueOrTournmentSeason;
  LeagueOrTournamentDivison leagueOrTournmentDivison;
  LeagueOrTournamentTeam leagueOrTournamentTeam;

  void initState() {
    super.initState();
    // Start trying to load the team.
    loadDetails();
  }

  void loadDetails() async {
    leagueOrTournamentTeam = await UserDatabaseData.instance.updateModel
        .getLeagueTeamData(widget.leagueOrTournamentTeamUid);
    // Update the UX.
    setState(() => true);

    if (leagueOrTournamentTeam != null) {
      // load a bit more stuff.
      leagueOrTournmentDivison = await UserDatabaseData.instance.updateModel
          .getLeagueDivisionData(
              leagueOrTournamentTeam.leagueOrTournamentDivisonUid);
      setState(() => true);
    }

    if (leagueOrTournmentDivison != null) {
      // Load the rest.
      leagueOrTournmentSeason = await UserDatabaseData.instance.updateModel
          .getLeagueSeasonData(
              leagueOrTournmentDivison.leagueOrTournmentSeasonUid);
      setState(() => true);
    }
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
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.
    assert(leagueOrTournmentSeason != null);
    assert(leagueOrTournmentDivison != null);
    assert(leagueOrTournament != null);

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        LeagueOrTournamentTeamName(
          widget.leagueOrTournamentTeamUid,
          style: Theme.of(context).textTheme.headline,
        ),
        Text("${_seasonName()} ${_divisonName()}",
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
            List<GameSharedData> sortedGames = games.where((GameSharedData g) =>
                g.officalResults.homeTeamLeagueUid ==
                    widget.leagueOrTournamentTeamUid ||
                g.officalResults.awayTeamLeagueUid ==
                    widget.leagueOrTournamentTeamUid);
            if (sortedGames.length == 0) {
              return Text(Messages.of(context).nogames);
            }

            sortedGames.sort((GameSharedData g1, GameSharedData g2) =>
                (g1.time - g2.time).toInt());
            return Column(
              children: sortedGames
                  .map((GameSharedData g) => GameSharedCard(g))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
