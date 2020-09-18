import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentseasonprovider.dart';

class LeagueOrTournamentSeasonName extends StatelessWidget {
  LeagueOrTournamentSeasonName(
      {@required this.leagueOrTournmentSeasonUid,
      @required this.leagueBloc,
      this.style,
      this.textAlign,
      this.overflow});

  final String leagueOrTournmentSeasonUid;
  final SingleLeagueOrTournamentBloc leagueBloc;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentSeasonProvider(
      leagueSeasonUid: leagueOrTournmentSeasonUid,
      builder:
          (BuildContext context, SingleLeagueOrTournamentSeasonBloc bloc) =>
              BlocBuilder(
        cubit: bloc,
        builder:
            (BuildContext context, SingleLeagueOrTournamentSeasonState state) {
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
              state.season.name,
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
