import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Picks a leagur or tournament team from the specified divison to
/// set for a game.
///
class TournamentOrLeagueTeamPicker extends StatefulWidget {
  /// Constructor.
  TournamentOrLeagueTeamPicker(
      {@required this.onChanged,
      @required this.leagueOrTournamentDivisonBloc,
      this.initialTeamUid,
      this.disabled = false,
      this.selectedTitle = false,
      this.includeAll = false}) {
    leagueOrTournamentDivisonBloc
        .add(SingleLeagueOrTournamentDivisonLoadTeams());
  }

  /// Called when the value changes.
  final ValueChanged<String> onChanged;

  /// The bloc associated with the division to get the teams from.
  final SingleLeagueOrTournamentDivisonBloc leagueOrTournamentDivisonBloc;

  /// If it is disabled.
  final bool disabled;

  /// If the title is selected.
  final bool selectedTitle;

  /// The initial team selected.
  final String initialTeamUid;

  /// If we should include all the teams. (extra drop down item)
  final bool includeAll;

  /// Constant used to identify 'all' teams.
  static const String all = 'all';

  @override
  _TournamentOrLeagueTeamPickerState createState() {
    return _TournamentOrLeagueTeamPickerState();
  }
}

class _TournamentOrLeagueTeamPickerState
    extends State<TournamentOrLeagueTeamPicker> {
  _TournamentOrLeagueTeamPickerState();

  List<DropdownMenuItem<String>> _buildItems(
      Iterable<LeagueOrTournamentTeam> teams) {
    var ret = <DropdownMenuItem<String>>[];
    if (widget.includeAll) {
      ret.add(DropdownMenuItem<String>(
        value: TournamentOrLeagueTeamPicker.all,
        child: Text(Messages.of(context).allteams),
      ));
    }
    for (var team in teams) {
      ret.add(DropdownMenuItem<String>(
        value: team.uid,
        child: Text(team.name),
      ));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: Messages.of(context).team,
        labelStyle: widget.selectedTitle
            ? Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: BlocBuilder(
        cubit: widget.leagueOrTournamentDivisonBloc,
        builder: (context, state) {
          widget.leagueOrTournamentDivisonBloc
              .add(SingleLeagueOrTournamentDivisonLoadTeams());
          if (state.teams.length == 0) {
            if (widget.disabled) {
              return Text(
                Messages.of(context).teamselect,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).disabledColor, height: 3.0),
              );
            }
            return Text(
              Messages.of(context).loading,
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(height: 3.0),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: widget.disabled
                    ? Text(
                        Messages.of(context).teamselect,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context).disabledColor,
                            height: 3.0),
                      )
                    : DropdownButton<String>(
                        key: Key('LEAGUETEAM'),
                        hint: Text(Messages.of(context).teamselect),
                        items: _buildItems(state.teams.values),
                        value: widget.initialTeamUid,
                        onChanged: (val) {
                          widget.onChanged(val);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
