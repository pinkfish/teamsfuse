import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentteamprovider.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/leagueortournament/addinvitetoteamdialog.dart';
import '../../widgets/leagueortournament/leagueortournamentteam.dart';
import '../../widgets/leagueortournament/leagueortournamentteamname.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// SHow the team in the league with all the related details.
///
class LeagueTeamScreen extends StatelessWidget {
  /// Constructor.
  LeagueTeamScreen(this.leagueTeamUid);

  /// The season in the league to lookup.
  final String leagueTeamUid;

  void _doAction(
      BuildContext context, String action, SingleLeagueOrTournamentBloc bloc) {
    if (action == "invite") {
      AddInviteToTeamDialog.showAddTeamInviteDialogByUid(
          context, leagueTeamUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentTeamProvider(
      leagueTeamUid: leagueTeamUid,
      builder: (context, bloc) => BlocConsumer(
        cubit: bloc,
        listener: (context, state) {
          if (state is SingleLeagueOrTournamentTeamDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          FloatingActionButton fab;
          var actions = <Widget>[];

          if (!(state is SingleLeagueOrTournamentTeamUninitialized)) {
            if (!(state is SingleLeagueOrTournamentTeamUninitialized)) {
              // lets load the league.
              if (state.league.isAdmin()) {
                actions.add(
                  SingleLeagueOrTournamentProvider(
                    leagueUid: state.divison.leagueOrTournmentUid,
                    builder: (context, leagueBloc) => BlocBuilder(
                      cubit: leagueBloc,
                      builder: (context, leagueState) {
                        if (!(leagueState
                            is SingleLeagueOrTournamentUninitialized)) {
                          return PopupMenuButton<String>(
                            onSelected: (str) =>
                                _doAction(context, str, leagueBloc),
                            itemBuilder: (context) {
                              return <PopupMenuItem<String>>[
                                PopupMenuItem<String>(
                                  value: "invite",
                                  child:
                                      Text(Messages.of(context).addteamadmin),
                                ),
                              ];
                            },
                          );
                        }
                        return SizedBox(
                          width: 0.0,
                        );
                      },
                    ),
                  ),
                );
              }
            }
            return Scaffold(
              appBar: AppBar(
                title: LeagueOrTournamentTeamName(leagueTeamUid),
                actions: actions,
              ),
              floatingActionButton: fab,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body: SavingOverlay(
                saving: state is SingleLeagueOrTournamentSaving,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: LeagueOrTournamentTeamDetails(
                      leagueOrTournamentTeamUid: leagueTeamUid,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
