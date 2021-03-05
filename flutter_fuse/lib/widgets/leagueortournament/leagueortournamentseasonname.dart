import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';

///
/// Display the season name for the league or tournament.
///
class LeagueOrTournamentSeasonName extends StatelessWidget {
  /// Constructor.
  LeagueOrTournamentSeasonName(
      {@required this.leagueOrTournmentSeasonUid,
      this.style,
      this.textAlign,
      this.overflow});

  /// The season uid to lookup.
  final String leagueOrTournmentSeasonUid;

  /// The style to use.
  final TextStyle style;

  /// The text alignmenet to use.
  final TextAlign textAlign;

  /// The text overflow to use.
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentSeasonProvider(
      leagueSeasonUid: leagueOrTournmentSeasonUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          Widget inner;
          if (state is SingleLeagueOrTournamentSeasonDeleted) {
            inner = Text(
              Messages.of(context).unknown,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else if (state is SingleLeagueOrTournamentSeasonUninitialized) {
            inner = Text(
              Messages.of(context).loading,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else {
            inner = Text(
              state.season.name,
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
