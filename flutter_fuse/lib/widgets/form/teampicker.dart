import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';

class TeamPicker extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String teamUid;

  TeamPicker({ @required this.onChanged,this.teamUid});

  TeamPickerState createState() {
    return new TeamPickerState();
  }
}

class TeamPickerState extends State<TeamPicker> {
  String _value;
  StreamSubscription<UpdateReason> teamStresm;

  TeamPickerState();
  @override
  void dispose() {
    super.dispose();
    teamStresm.cancel();
    teamStresm = null;
  }

  void initState() {
    teamStresm = UserDatabaseData.instance.teamStream.listen((update) {
      setState(() {});
    });
    _value = widget.teamUid;
  }

  List<DropdownMenuItem> _buildItems() {
    List<DropdownMenuItem> ret = new List<DropdownMenuItem>();
    UserDatabaseData.instance.teams.forEach((key, team) {
      ret.add(new DropdownMenuItem(
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
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: new DropdownButton(
              hint: new Text(Messages.of(context).teamselect),
              items: _buildItems(),
              value: this._value,
              onChanged: (dynamic val) {
                _value = val;
                this.widget.onChanged(val);
                return val;
              },
            ),
          ),
        ],
      ),
    );
  }
}
