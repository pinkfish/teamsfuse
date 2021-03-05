import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Shows a picker to let you select a team.
///
class TeamPicker extends StatelessWidget {
  /// Constructor.
  TeamPicker(
      {@required this.onChanged,
      this.teamUid,
      this.includeCreateNew = false,
      this.disabled = false,
      this.selectedTitle = false});

  /// Called when the value has changed.
  final ValueChanged<String> onChanged;

  /// The currently selected teamUid
  final String teamUid;

  /// If it is disabled.
  final bool disabled;

  /// The title is selected.
  final bool selectedTitle;

  /// Allow for a create new item.
  final bool includeCreateNew;

  /// The item to say a new item should be created.
  static const String createNew = 'new';

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, TeamState state) {
    var ret = <DropdownMenuItem<String>>[];
    if (includeCreateNew) {
      ret.add(DropdownMenuItem<String>(
        value: TeamPicker.createNew,
        child: Text(Messages.of(context).addTeam),
      ));
    }
    for (var teamUid in state.allTeamUids) {
      var team = state.getTeam(teamUid);
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
        labelStyle: selectedTitle
            ? Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: disabled
                  ? Text(
                      Messages.of(context).teamselect,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).disabledColor, height: 3.0),
                    )
                  : BlocBuilder(
                      cubit: BlocProvider.of<TeamBloc>(context),
                      builder: (context, state) {
                        return DropdownButton<String>(
                          key: Key('TEAM'),
                          hint: Text(Messages.of(context).teamselect),
                          items: _buildItems(context, state),
                          value: teamUid,
                          onChanged: onChanged,
                        );
                      })),
        ],
      ),
    );
  }
}
