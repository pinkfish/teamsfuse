import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

///
/// Picks a leagur or tournament team from the specified divison to
/// set for a game.
///
class TournamentOrLeagueTeamPicker extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String tournamentOrLeagueDivisonUid;
  final bool disabled;
  final bool selectedTitle;
  final String initialTeamUid;
  final bool includeAll;

  TournamentOrLeagueTeamPicker(
      {@required this.onChanged,
      @required this.tournamentOrLeagueDivisonUid,
      this.initialTeamUid,
      this.disabled = false,
      this.selectedTitle = false,
      this.includeAll = false});

  static const String all = 'all';

  @override
  _TournamentOrLeagueTeamPickerState createState() {
    return new _TournamentOrLeagueTeamPickerState();
  }
}

class _TournamentOrLeagueTeamPickerState
    extends State<TournamentOrLeagueTeamPicker> {
  LeagueOrTournmentTeamSubscription _teamSub;

  _TournamentOrLeagueTeamPickerState();
  @override
  void dispose() {
    super.dispose();
    _teamSub?.dispose();
    _teamSub = null;
  }

  @override
  void initState() {
    super.initState();
    _teamSub = UserDatabaseData.instance.updateModel
        .getLeagueDivisionTeams(widget.tournamentOrLeagueDivisonUid);
  }

  List<DropdownMenuItem<String>> _buildItems(
      Iterable<LeagueOrTournamentTeam> teams) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    if (widget.includeAll) {
      ret.add(new DropdownMenuItem<String>(
        child: Text(Messages.of(context).allteams),
        value: TournamentOrLeagueTeamPicker.all,
      ));
    }
    for (LeagueOrTournamentTeam team in teams) {
      ret.add(new DropdownMenuItem<String>(
        child: new Text(team.name),
        value: team.uid,
      ));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return new InputDecorator(
      decoration: new InputDecoration(
        labelText: Messages.of(context).team,
        labelStyle: widget.selectedTitle
            ? Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: StreamBuilder(
          stream: _teamSub.stream,
          builder: (BuildContext context,
              AsyncSnapshot<Iterable<LeagueOrTournamentTeam>> snap) {
            if (!snap.hasData) {
              if (widget.disabled) {
                return Text(
                  Messages.of(context).teamselect,
                  style: Theme.of(context).textTheme.body1.copyWith(
                      color: Theme.of(context).disabledColor, height: 3.0),
                );
              }
              return new Text(
                Messages.of(context).loading,
                style: Theme.of(context).textTheme.body1.copyWith(height: 3.0),
              );
            }
            return new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Expanded(
                  flex: 1,
                  child: widget.disabled
                      ? new Text(
                          Messages.of(context).teamselect,
                          style: Theme.of(context).textTheme.body1.copyWith(
                              color: Theme.of(context).disabledColor,
                              height: 3.0),
                        )
                      : new DropdownButton<String>(
                          hint: new Text(Messages.of(context).teamselect),
                          items: _buildItems(snap.data),
                          value: widget.initialTeamUid,
                          onChanged: (String val) {
                            widget.onChanged(val);
                          },
                        ),
                ),
              ],
            );
          }),
    );
  }
}
