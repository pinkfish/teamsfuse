import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentdivisonprovider.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../util/communityicons.dart';
import '../util/teamimage.dart';
import 'leagueortournamentteamname.dart';

///
/// Card showing details of a team inside a league/tournament.
///
class LeagueOrTournamentTeamCard extends StatelessWidget {
  /// Constructor.
  LeagueOrTournamentTeamCard(this.team, {this.admin = false});

  /// The team in the league to display
  final LeagueOrTournamentTeam team;

  /// If we are an admin in this team
  final bool admin;

  @override
  Widget build(BuildContext context) {
    Widget subtitle;

    return Card(
      child: SingleLeagueOrTournamentDivisonProvider(
        leagueDivisonUid: team.leagueOrTournamentDivisonUid,
        builder: (context, divisonBloc) => BlocBuilder(
            cubit: divisonBloc,
            builder: (context, divisonState) {
              if (divisonBloc != SingleLeagueOrTournamentDivisonUninitialized) {
                if (team.record.containsKey(divisonState.divison.uid)) {
                  subtitle = Text(Messages.of(context)
                      .winrecord(team.record[divisonState.divison.uid]));
                } else {
                  var record = WinRecord();
                  subtitle = Text(Messages.of(context).winrecord(record));
                }
              }
              return ListTile(
                onTap: () =>
                    Navigator.pushNamed(context, "/League/Team/${team.uid}"),
                leading: team.teamUid != null
                    ? TeamImage(
                        width: 50.0,
                        height: 50.0,
                        teamUid: team.teamUid,
                      )
                    : const Icon(
                        CommunityIcons.basketball,
                        size: 50.0,
                      ),
                title: Container(
                  alignment: Alignment.topLeft,
                  child: LeagueOrTournamentTeamName(
                    team.uid,
                    textAlign: TextAlign.start,
                  ),
                ),
                subtitle: subtitle,
              );
            }),
      ),
    );
  }
}
