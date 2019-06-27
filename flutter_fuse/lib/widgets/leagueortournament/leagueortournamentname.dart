import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

import '../blocs/singleleagueortournamentdivisonprovider.dart';
import '../blocs/singleleagueortournamentprovider.dart';

///
/// Puts the name of the league or tournament in the UX
///
class LeagueOrTournamentName extends StatelessWidget {
  LeagueOrTournamentName(this.leagueOrTournamentUid,
      {this.leagueOrTournamentDivisonUid, this.style, this.textAlign});

  final String leagueOrTournamentUid;
  final TextStyle style;
  final TextAlign textAlign;
  final String leagueOrTournamentDivisonUid;

  Widget _divison() {
    return SingleLeagueOrTournamentDivisonProvider(
      leagueOrTournamentDivisonUid: leagueOrTournamentDivisonUid,
      builder:
          (BuildContext context, SingleLeagueOrTournamentDivisonBloc data) =>
              BlocBuilder(
                bloc: data,
                builder: (BuildContext context,
                    SingleLeagueOrTournamentDivisonState state) {
                  Widget inner;
                  if (state is SingleLeagueOrTournamentDivisonDeleted) {
                    inner = Text(
                      "",
                      style: style,
                      textAlign: textAlign,
                      overflow: TextOverflow.ellipsis,
                    );
                  } else {
                    inner = Text(
                      state.leagueOrTournamentDivison.name,
                      style: style,
                      textAlign: textAlign,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return AnimatedSwitcher(
                    child: inner,
                    duration: Duration(milliseconds: 300),
                  );
                },
              ),
    );
  }

  Widget _name() {
    return SingleLeagueOrTournamentProvider(
      leagueOrTournamentUid: leagueOrTournamentUid,
      builder: (BuildContext context,
              SingleLeagueOrTournamentBloc singleLeagueOrTournmanetBloc) =>
          BlocBuilder(
            bloc: singleLeagueOrTournmanetBloc,
            builder:
                (BuildContext context, SingleLeagueOrTournamentState state) {
              Widget inner;

              if (SingleLeagueOrTournamentState
                  is SingleLeagueOrTournamentDeleted) {
                inner = Text(
                  Messages.of(context).loading,
                  style: style,
                  textAlign: textAlign,
                  overflow: TextOverflow.ellipsis,
                );
              } else {
                inner = Text(
                  state.leagueOrTournament.name,
                  style: style,
                  textAlign: textAlign,
                );
              }
              return AnimatedSwitcher(
                child: inner,
                duration: Duration(milliseconds: 300),
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
