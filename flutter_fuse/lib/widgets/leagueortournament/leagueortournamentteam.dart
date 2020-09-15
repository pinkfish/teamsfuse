import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamesharedcard.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';
import '../blocs/singleleagueortournamentteamprovider.dart';
import 'addinvitetoteamdialog.dart';
import 'leagueortournamentdivisonname.dart';
import 'leagueortournamentname.dart';
import 'leagueortournamentseasonname.dart';

///
/// The details to display in the app about the team in a league or
/// tournament.
///
class LeagueOrTournamentTeamDetails extends StatefulWidget {
  LeagueOrTournamentTeamDetails(
      {@required this.leagueOrTournamentTeamUid,
      @required this.leagueOrTournamentUid});

  final String leagueOrTournamentTeamUid;
  final String leagueOrTournamentUid;

  @override
  State createState() {
    return new _LeagueOrTournamentTeamDetailsState();
  }
}

class _LeagueOrTournamentTeamDetailsState
    extends State<LeagueOrTournamentTeamDetails> {
  void _onDelete() {}

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // We must have the league/season loaded to have got in here.  If not
    // this is an error.

    return Container(
      margin: EdgeInsets.all(5.0),
      child: SingleLeagueOrTournamentTeamProvider(
        leagueTeamUid: widget.leagueOrTournamentTeamUid,
        builder:
            (BuildContext context, SingleLeagueOrTournamentTeamBloc bloc) =>
                BlocListener(
          cubit: bloc,
          listener: (BuildContext context,
              SingleLeagueOrTournamentTeamState teamState) {
            if (teamState is SingleLeagueOrTournamentTeamLoaded) {
              bloc.add(SingleLeagueOrTournamentTeamLoadInvites());
            }
          },
          child: BlocBuilder(
              cubit: bloc,
              builder: (BuildContext context,
                  SingleLeagueOrTournamentTeamState teamState) {
                if (teamState is SingleLeagueOrTournamentTeamUninitialized ||
                    teamState is SingleLeagueOrTournamentTeamDeleted) {
                  return Center(child: Text(Messages.of(context).loading));
                }

                return SingleLeagueOrTournamentProvider(
                  leagueUid: widget.leagueOrTournamentUid,
                  builder: (BuildContext context,
                          SingleLeagueOrTournamentBloc leagueBloc) =>
                      SingleLeagueOrTournamentSeasonProvider(
                    leagueSeasonUid: teamState.leagueOrTournamentTeam.seasonUid,
                    builder: (BuildContext context,
                            SingleLeagueOrTournamentSeasonBloc seasonBloc) =>
                        SingleLeagueOrTournamentDivisonProvider(
                            leagueDivisonUid: teamState.leagueOrTournamentTeam
                                .leagueOrTournamentDivisonUid,
                            builder: (BuildContext context,
                                SingleLeagueOrTournamentDivisonBloc
                                    divisonBloc) {
                              divisonBloc.add(
                                  SingleLeagueOrTournamentDivisonLoadGames());
                              return BlocBuilder(
                                cubit: leagueBloc,
                                builder: (BuildContext context,
                                        SingleLeagueOrTournamentState
                                            leagueState) =>
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    LeagueImage(
                                      leagueOrTournamentUid:
                                          widget.leagueOrTournamentUid,
                                      width: (screenSize.width < 500)
                                          ? 120.0
                                          : (screenSize.width / 4) + 12.0,
                                      height: screenSize.height / 4 + 20,
                                    ),
                                    LeagueOrTournamentName(
                                      widget.leagueOrTournamentUid,
                                      style:
                                          Theme.of(context).textTheme.headline,
                                    ),
                                    LeagueOrTournamentSeasonName(
                                        leagueBloc: leagueBloc,
                                        leagueOrTournmentSeasonUid: teamState
                                            .leagueOrTournamentTeam.seasonUid,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .copyWith(
                                                fontWeight: FontWeight.bold)),
                                    LeagueOrTournamentDivisonName(
                                        leagueOrTournmentDivisonUid: teamState
                                            .leagueOrTournamentTeam
                                            .leagueOrTournamentDivisonUid,
                                        leagueSeasonBloc: seasonBloc,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subhead),
                                    BlocBuilder(
                                      cubit: divisonBloc,
                                      builder: (BuildContext context,
                                          SingleLeagueOrTournamentDivisonState
                                              gamesState) {
                                        if (gamesState
                                            is SingleLeagueOrTournamentDivisonUninitialized) {
                                          return Text(
                                              Messages.of(context).loading);
                                        }

                                        List<GameSharedData> sortedGames = gamesState
                                            .games.values
                                            .where((GameSharedData g) =>
                                                g.officialResult
                                                        .homeTeamLeagueUid ==
                                                    widget
                                                        .leagueOrTournamentTeamUid ||
                                                g.officialResult
                                                        .awayTeamLeagueUid ==
                                                    widget
                                                        .leagueOrTournamentTeamUid)
                                            .toList();
                                        if (sortedGames.length == 0) {
                                          return Text(
                                              Messages.of(context).nogames);
                                        }

                                        sortedGames.sort((GameSharedData g1,
                                                GameSharedData g2) =>
                                            (g1.time - g2.time).toInt());
                                        List<Widget> children = sortedGames
                                            .map<Widget>((GameSharedData g) =>
                                                GameSharedCard(g))
                                            .toList();

                                        if (teamState.leagueOrTournamentTeam
                                                    .uid ==
                                                null &&
                                            leagueState.league.isAdmin()) {
                                          children.add(new ExpansionTile(
                                            title: Text(
                                              Messages.of(context)
                                                  .invitedpeople(
                                                      teamState.invites.length),
                                            ),
                                            initiallyExpanded: false,
                                            children: teamState.invites.map(
                                                (InviteToLeagueTeam invite) {
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
                                                  FlatButton(
                                                    onPressed: () =>
                                                        AddInviteToTeamDialog
                                                            .showAddTeamInviteDialog(
                                                                context, bloc),
                                                    child: Text(
                                                      Messages.of(context)
                                                          .addteamadmin,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .button
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
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
                              );
                            }),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
