import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';

///
/// Puts the name of the league or tournament in the UX
///
class LeagueOrTournamentName extends StatelessWidget {
  /// Constructor.
  LeagueOrTournamentName(this.leagueOrTournamentUid,
      {this.leagueOrTournamentDivisonUid, this.style, this.textAlign});

  /// The league or tournament to lookup.
  final String leagueOrTournamentUid;

  /// The style to display.
  final TextStyle style;

  /// The alignment to use.
  final TextAlign textAlign;

  /// The divison id to use.
  final String leagueOrTournamentDivisonUid;

  Widget _divison() {
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: leagueOrTournamentDivisonUid,
      builder: (context, data) => BlocBuilder(
        bloc: data,
        builder: (context, state) {
          Widget inner;
          if (state is SingleLeagueOrTournamentDivisonDeleted) {
            inner = Text(
              '',
              style: style,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            inner = Text(
              state.divison.name,
              style: style,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
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

  Widget _name() {
    return SingleLeagueOrTournamentProvider(
      leagueUid: leagueOrTournamentUid,
      builder: (context, singleLeagueOrTournmanetBloc) => BlocBuilder(
        bloc: singleLeagueOrTournmanetBloc,
        builder: (context, state) {
          Widget inner;

          if (state is SingleLeagueOrTournamentDeleted ||
              state is SingleLeagueOrTournamentUninitialized) {
            inner = Text(
              Messages.of(context).loading,
              style: style,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            inner = Text(
              state.league.name,
              style: style,
              textAlign: textAlign,
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

  @override
  Widget build(BuildContext context) {
    if (leagueOrTournamentDivisonUid == null) {
      return _name();
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _divison(),
        SizedBox(
          width: 15.0,
        ),
        Flexible(child: _name()),
      ],
    );
  }
}
