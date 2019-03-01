import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class TeamPicker extends StatefulWidget {
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

  @override
  TeamPickerState createState() {
    return new TeamPickerState();
  }

  static const String createNew = 'new';
}

class TeamPickerState extends State<TeamPicker> {
  StreamSubscription<UpdateReason> _teamStream;

  @override
  void dispose() {
    super.dispose();
    _teamStream?.cancel();
    _teamStream = null;
  }

  @override
  void initState() {
    _teamStream =
        UserDatabaseData.instance.teamStream.listen((UpdateReason update) {
      setState(() {});
    });
    super.initState();
  }

  List<DropdownMenuItem<String>> _buildItems() {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    if (widget.includeCreateNew) {
      ret.add(DropdownMenuItem<String>(
        child: Text(Messages.of(context).addteam),
        value: TeamPicker.createNew,
      ));
    }
    UserDatabaseData.instance.teams.forEach((String key, Team team) {
      ret.add(new DropdownMenuItem<String>(
        child: new Text(team.name),
        value: team.uid,
      ));
    });
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
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: widget.disabled
                ? new Text(
                    Messages.of(context).teamselect,
                    style: Theme.of(context).textTheme.body1.copyWith(
                        color: Theme.of(context).disabledColor, height: 3.0),
                  )
                : new DropdownButton<String>(
                    hint: new Text(Messages.of(context).teamselect),
                    items: _buildItems(),
                    value: widget.teamUid,
                    onChanged: (String val) {
                      widget.onChanged(val);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
