import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamPicker extends StatelessWidget {
  TeamPicker(
      {@required this.onChanged,
      this.teamUid,
      this.includeCreateNew = false,
      this.disabled = false,
      this.selectedTitle = false});

  final ValueChanged<String> onChanged;
  final String teamUid;
  final bool disabled;
  final bool selectedTitle;
  final bool includeCreateNew;

  static const String createNew = 'new';

  List<DropdownMenuItem<String>> _buildItems(
      BuildContext context, TeamState state) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    if (includeCreateNew) {
      ret.add(DropdownMenuItem<String>(
        child: Text(Messages.of(context).addteam),
        value: TeamPicker.createNew,
      ));
    }
    for (Team team in state.teams.values) {
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
        labelStyle: selectedTitle
            ? Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(
              flex: 1,
              child: disabled
                  ? new Text(
                      Messages.of(context).teamselect,
                      style: Theme.of(context).textTheme.body1.copyWith(
                          color: Theme.of(context).disabledColor, height: 3.0),
                    )
                  : BlocBuilder<TeamEvent, TeamState>(
                      bloc: BlocProvider.of<TeamBloc>(context),
                      builder: (BuildContext context, TeamState state) {
                        DropdownButton<String>(
                          hint: new Text(Messages.of(context).teamselect),
                          items: _buildItems(context, state),
                          value: teamUid,
                          onChanged: (String val) {
                            onChanged(val);
                          },
                        );
                      })),
        ],
      ),
    );
  }
}
