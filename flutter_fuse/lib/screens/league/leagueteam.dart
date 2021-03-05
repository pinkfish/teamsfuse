import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentprovider.dart';
import '../../widgets/blocs/singleleagueortournamentteamprovider.dart';
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
    if (action == 'invite') {
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
        builder: (context, SingleLeagueOrTournamentTeamState state) {
          FloatingActionButton fab;
          var actions = <Widget>[];

          if (!(state is SingleLeagueOrTournamentTeamUninitialized)) {
            // lets load the league.
            actions.add(
              SingleLeagueOrTournamentProvider(
                leagueUid: state.leagueOrTournamentTeam.leagueOrTournamentUid,
                builder: (context, leagueBloc) => BlocBuilder(
                  cubit: leagueBloc,
                  builder: (context, leagueState) {
                    if (leagueState is SingleLeagueOrTournamentLoaded &&
                        leagueState.league.isAdmin()) {
                      return PopupMenuButton<String>(
                        onSelected: (str) =>
                            _doAction(context, str, leagueBloc),
                        itemBuilder: (context) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              value: 'invite',
                              child: Text(Messages.of(context).shareTeam),
                            ),
                          ];
                        },
                      );
                    }
                    return SizedBox(width: 0, height: 0);
                  },
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: LeagueOrTournamentTeamName(leagueTeamUid),
              actions: actions,
            ),
            floatingActionButton: fab,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: SavingOverlay(
              saving: state is SingleLeagueOrTournamentTeamSaving,
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: LeagueOrTournamentTeamDetails(
                    leagueOrTournamentTeamUid: leagueTeamUid,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
