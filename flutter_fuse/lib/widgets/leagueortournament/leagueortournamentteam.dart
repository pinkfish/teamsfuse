import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentteamprovider.dart';
import '../games/gamesharedcard.dart';
import 'addinvitetoteamdialog.dart';
import 'leagueimage.dart';
import 'leagueortournamentdivisonname.dart';
import 'leagueortournamentname.dart';
import 'leagueortournamentseasonname.dart';

///
/// The details to display in the app about the team in a league or
/// tournament.
///
class LeagueOrTournamentTeamDetails extends StatefulWidget {
  /// Constructor.
  LeagueOrTournamentTeamDetails({@required this.leagueOrTournamentTeamUid});

  /// The team uid to display.
  final String leagueOrTournamentTeamUid;

  @override
  State createState() {
    return _LeagueOrTournamentTeamDetailsState();
  }
}

class _LeagueOrTournamentTeamDetailsState
    extends State<LeagueOrTournamentTeamDetails> {
  void _onDelete() {}

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.

    return Container(
      margin: EdgeInsets.all(5.0),
      child: SingleLeagueOrTournamentTeamProvider(
        leagueTeamUid: widget.leagueOrTournamentTeamUid,
        builder: (context, bloc) => BlocBuilder(
            bloc: bloc,
            builder: (context, SingleLeagueOrTournamentTeamState teamState) {
              if (teamState is SingleLeagueOrTournamentTeamUninitialized ||
                  teamState is SingleLeagueOrTournamentTeamDeleted) {
                return Center(child: Text(Messages.of(context).loading));
              }

              if (!teamState.loadedGames) {
                bloc.add(SingleLeagueOrTournamentTeamLoadGames());
              }

              if (!teamState.loadedInvites) {
                bloc.add(SingleLeagueOrTournamentTeamLoadInvites());
              }

              return SingleLeagueOrTournamentProvider(
                leagueUid:
                    teamState.leagueOrTournamentTeam.leagueOrTournamentUid,
                builder: (context, leagueBloc) => BlocBuilder(
                  bloc: leagueBloc,
                  builder: (context, leagueState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      LeagueImage(
                        leagueOrTournamentUid: teamState
                            .leagueOrTournamentTeam.leagueOrTournamentUid,
                        width: (screenSize.width < 500)
                            ? 120.0
                            : (screenSize.width / 4) + 12.0,
                        height: screenSize.height / 4 + 20,
                      ),
                      LeagueOrTournamentName(
                        teamState.leagueOrTournamentTeam.leagueOrTournamentUid,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      LeagueOrTournamentSeasonName(
                          leagueOrTournmentSeasonUid: teamState
                              .leagueOrTournamentTeam
                              .leagueOrTournamentSeasonUid,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontWeight: FontWeight.bold)),
                      LeagueOrTournamentDivisonName(
                          leagueOrTournmentDivisonUid: teamState
                              .leagueOrTournamentTeam
                              .leagueOrTournamentDivisonUid,
                          style: Theme.of(context).textTheme.subtitle1),
                      Builder(
                        builder: (context) {
                          if (!teamState.loadedGames) {
                            bloc.add(SingleLeagueOrTournamentTeamLoadGames());
                          }

                          var sortedGames = teamState.games.values
                              .where((g) =>
                                  g.officialResult.homeTeamLeagueUid ==
                                      widget.leagueOrTournamentTeamUid ||
                                  g.officialResult.awayTeamLeagueUid ==
                                      widget.leagueOrTournamentTeamUid)
                              .toList();
                          if (sortedGames.isEmpty) {
                            return Text(Messages.of(context).noGames);
                          }

                          sortedGames.sort(
                              (g1, g2) => (g1.time.compareTo(g2.time)).toInt());
                          var children = sortedGames
                              .map<Widget>((g) => GameSharedCard(g))
                              .toList();

                          if (teamState.leagueOrTournamentTeam.uid == null &&
                              leagueState.league.isAdmin()) {
                            children.add(ExpansionTile(
                              title: Text(
                                Messages.of(context)
                                    .invitedPeople(teamState.invites.length),
                              ),
                              initiallyExpanded: false,
                              children: teamState.invites.map((invite) {
                                return ListTile(
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: _onDelete,
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
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () => AddInviteToTeamDialog
                                          .showAddTeamInviteDialog(
                                              context, bloc),
                                      child: Text(
                                        Messages.of(context).addInviteButton,
                                        style: Theme.of(context)
                                            .textTheme
                                            .button
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .accentColor),
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
                  ),
                ),
              );
            }),
      ),
    );
  }
}
