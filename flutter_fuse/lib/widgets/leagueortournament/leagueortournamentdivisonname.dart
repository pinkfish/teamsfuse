import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentdivisonprovider.dart';

///
/// Setup the divison name for the league or tournament.
///
class LeagueOrTournamentDivisonName extends StatelessWidget {
  /// Constructor.
  LeagueOrTournamentDivisonName(
      {@required this.leagueOrTournmentDivisonUid,
      this.style,
      this.textAlign,
      this.overflow});

  /// The league or tournament divison to get the name of.
  final String leagueOrTournmentDivisonUid;

  /// The text style for the name
  final TextStyle style;

  /// The text alignment to use.
  final TextAlign textAlign;

  /// The overflow to use.
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: leagueOrTournmentDivisonUid,
      builder: (context, bloc) => BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          Widget inner;
          if (state is SingleLeagueOrTournamentDivisonDeleted) {
            inner = Text(
              Messages.of(context).unknown,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else if (state is SingleLeagueOrTournamentDivisonUninitialized) {
            inner = Text(
              Messages.of(context).loading,
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            );
          } else {
            inner = Text(
              state.divison.name,
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
