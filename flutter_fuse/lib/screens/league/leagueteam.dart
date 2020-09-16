import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentprovider.dart';
import '../../widgets/leagueortournament/addinvitetoteamdialog.dart';
import '../../widgets/leagueortournament/leagueortournamentteam.dart';
import '../../widgets/leagueortournament/leagueortournamentteamname.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// SHow the team in the league with all the related details.
///
class LeagueTeamScreen extends StatelessWidget {
  /// Constructor.
  LeagueTeamScreen(this.leagueUid, this.leagueSeasonUid, this.leagueTeamUid);

  /// The team in the league.
  final String leagueTeamUid;

  /// The league to lookup.
  final String leagueUid;

  /// The season in the league to lookup.
  final String leagueSeasonUid;

  void _doAction(
      BuildContext context, String action, SingleLeagueOrTournamentBloc bloc) {
    if (action == "invite") {
      AddInviteToTeamDialog.showAddTeamInviteDialogByUid(
          context, bloc, leagueSeasonUid, leagueTeamUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentProvider(
      leagueUid: leagueUid,
      builder: (context, bloc) => BlocListener(
        cubit: bloc,
        listener: (context, state) {
          if (state is SingleLeagueOrTournamentDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: bloc,
          builder: (context, state) {
            FloatingActionButton fab;
            var actions = <Widget>[];

            if (!(state is SingleLeagueOrTournamentDeleted)) {
              if (state.league.isAdmin()) {
                actions.add(
                  PopupMenuButton<String>(
                    onSelected: (str) => _doAction(context, str, bloc),
                    itemBuilder: (context) {
                      return <PopupMenuItem<String>>[
                        PopupMenuItem<String>(
                          value: "invite",
                          child: Text(Messages.of(context).addteamadmin),
                        ),
                      ];
                    },
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
                      leagueOrTournamentUid: leagueUid,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
