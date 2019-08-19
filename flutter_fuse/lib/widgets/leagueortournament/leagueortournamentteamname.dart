import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

import '../blocs/singleleagueortournamentteamprovider.dart';

class LeagueOrTournamentTeamName extends StatelessWidget {
  LeagueOrTournamentTeamName(this.leagueOrTournmentTeamUid,
      {this.style, this.textAlign, this.overflow});

  final String leagueOrTournmentTeamUid;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentTeamProvider(
      leagueTeamUid: leagueOrTournmentTeamUid,
      builder: (BuildContext context, SingleLeagueOrTournamentTeamBloc bloc) =>
          BlocBuilder(
        bloc: bloc,
        builder:
            (BuildContext context, SingleLeagueOrTournamentTeamState state) {
          Widget inner;
          if (state is SingleLeagueOrTournamentTeamLoading) {
            inner = Text(
              Messages.of(context).loading,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else if (state is SingleLeagueOrTournamentTeamDeleted) {
            inner = Text(
              Messages.of(context).unknown,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else {
            inner = Text(
              state.leagueOrTournamentTeam.name,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          }

          return AnimatedSwitcher(
              child: inner, duration: Duration(milliseconds: 300));
        },
      ),
    );
  }
}
