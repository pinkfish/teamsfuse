import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addinvitetoteamdialog.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteam.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentteamname.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';

import '../../widgets/blocs/singleleagueortournamentprovider.dart';

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
              if (state.leagueOrTournament.isAdmin()) {
                actions.add(
                  new PopupMenuButton<String>(
                    onSelected: (String str) => _doAction(context, str, bloc),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuItem<String>>[
                        new PopupMenuItem<String>(
                          value: "invite",
                          child: new Text(Messages.of(context).addteamadmin),
                        ),
                      ];
                    },
                  ),
                );
              }
            }
            return Scaffold(
              appBar: new AppBar(
                title: new LeagueOrTournamentTeamName(leagueTeamUid),
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
