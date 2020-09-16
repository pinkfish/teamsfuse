import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentprovider.dart';
import '../../widgets/leagueortournament/addinvitetoteamdialog.dart';
import '../../widgets/leagueortournament/leagueortournamentteam.dart';
import '../../widgets/leagueortournament/leagueortournamentteamname.dart';
import '../../widgets/util/savingoverlay.dart';

class LeagueTeamScreen extends StatelessWidget {
  LeagueTeamScreen(this.leagueUid, this.leagueSeasonUid, this.leagueTeamUid);

  final String leagueTeamUid;
  final String leagueUid;
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
      builder: (BuildContext context, SingleLeagueOrTournamentBloc bloc) =>
          BlocListener(
        cubit: bloc,
        listener: (BuildContext context, SingleLeagueOrTournamentState state) {
          if (state is SingleLeagueOrTournamentDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: bloc,
          builder: (BuildContext context, SingleLeagueOrTournamentState state) {
            FloatingActionButton fab;
            List<Widget> actions = <Widget>[];

            if (!(state is SingleLeagueOrTournamentDeleted)) {
              if (state.league.isAdmin()) {
                actions.add(
                  PopupMenuButton<String>(
                    onSelected: (String str) => _doAction(context, str, bloc),
                    itemBuilder: (BuildContext context) {
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
