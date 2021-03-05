import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentteamprovider.dart';

///
/// Show the name of the team in this league or tournament.
///
class LeagueOrTournamentTeamName extends StatelessWidget {
  /// Constructor.
  LeagueOrTournamentTeamName(this.leagueOrTournmentTeamUid,
      {this.style, this.textAlign, this.overflow});

  /// The teamUid to display.
  final String leagueOrTournmentTeamUid;

  /// The text style to use.
  final TextStyle style;

  /// How to align the text.
  final TextAlign textAlign;

  /// What to do with overflow.
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentTeamProvider(
      leagueTeamUid: leagueOrTournmentTeamUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          Widget inner;
          if (state is SingleLeagueOrTournamentTeamUninitialized) {
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
            duration: Duration(milliseconds: 300),
            child: inner,
          );
        },
      ),
    );
  }
}
