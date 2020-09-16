import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Picks a leagur or tournament team from the specified divison to
/// set for a game.
///
class TournamentOrLeagueTeamPicker extends StatefulWidget {
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

  final ValueChanged<String> onChanged;
  final SingleLeagueOrTournamentDivisonBloc leagueOrTournamentDivisonBloc;
  final bool disabled;
  final bool selectedTitle;
  final String initialTeamUid;
  final bool includeAll;

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
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    if (widget.includeAll) {
      ret.add(DropdownMenuItem<String>(
        child: Text(Messages.of(context).allteams),
        value: TournamentOrLeagueTeamPicker.all,
      ));
    }
    for (LeagueOrTournamentTeam team in teams) {
      ret.add(DropdownMenuItem<String>(
        child: Text(team.name),
        value: team.uid,
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
                .subhead
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: BlocProvider(
        create: (BuildContext context) => SingleLeagueOrTournamentDivisonBloc(
            db: RepositoryProvider.of<DatabaseUpdateModel>(context)),
        child: BlocBuilder(
          cubit: BlocProvider.of<SingleLeagueOrTournamentDivisonBloc>(context),
          builder: (BuildContext context,
              SingleLeagueOrTournamentDivisonState state) {
            BlocProvider.of<SingleLeagueOrTournamentDivisonBloc>(context)
                .add(SingleLeagueOrTournamentDivisonLoadTeams());
            if (state.teams.length == 0) {
              if (widget.disabled) {
                return Text(
                  Messages.of(context).teamselect,
                  style: Theme.of(context).textTheme.body1.copyWith(
                      color: Theme.of(context).disabledColor, height: 3.0),
                );
              }
              return Text(
                Messages.of(context).loading,
                style: Theme.of(context).textTheme.body1.copyWith(height: 3.0),
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
                          style: Theme.of(context).textTheme.body1.copyWith(
                              color: Theme.of(context).disabledColor,
                              height: 3.0),
                        )
                      : DropdownButton<String>(
                          hint: Text(Messages.of(context).teamselect),
                          items: _buildItems(state.teams.values),
                          value: widget.initialTeamUid,
                          onChanged: (String val) {
                            widget.onChanged(val);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
