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
  StreamSubscription<UpdateReason> _teamStream;

  TeamPickerState();
  @override
  void dispose() {
    super.dispose();
    _teamStream?.cancel();
    _teamStream = null;
  }

  void initState() {
    _teamStream = UserDatabaseData.instance.teamStream.listen((update) {
      setState(() {});
    });
    super.initState();
  }

  List<DropdownMenuItem<String>> _buildItems() {
    List<DropdownMenuItem<String>> ret = [];
    UserDatabaseData.instance.teams.forEach((key, team) {
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
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: new DropdownButton<String>(
              hint: new Text(Messages.of(context).teamselect),
              items: _buildItems(),
              value: widget.teamUid,
              onChanged: (String val) {
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
