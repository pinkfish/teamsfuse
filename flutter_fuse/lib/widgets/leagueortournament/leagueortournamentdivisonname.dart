import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentdivisonprovider.dart';

class LeagueOrTournamentDivisonName extends StatelessWidget {
  LeagueOrTournamentDivisonName(
      {@required this.leagueOrTournmentDivisonUid,
      @required this.leagueSeasonBloc,
      this.style,
      this.textAlign,
      this.overflow});

  final String leagueOrTournmentDivisonUid;
  final SingleLeagueOrTournamentSeasonBloc leagueSeasonBloc;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: leagueOrTournmentDivisonUid,
      singleLeagueOrTournamentSeasonBloc: leagueSeasonBloc,
      builder:
          (BuildContext context, SingleLeagueOrTournamentDivisonBloc bloc) =>
              BlocBuilder(
        cubit: bloc,
        builder:
            (BuildContext context, SingleLeagueOrTournamentDivisonState state) {
          Widget inner;
          if (state is SingleLeagueOrTournamentSeasonDeleted) {
            inner = Text(
              Messages.of(context).unknown,
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
