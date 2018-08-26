import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class ClubPicker extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String clubUid;
  final bool adminOnly;
  final bool selectedTitle;

  ClubPicker({
    @required this.onChanged,
    this.clubUid,
    this.adminOnly = true,
    this.selectedTitle = false,
  });

  static const String noClub = "noClub";

  List<DropdownMenuItem<String>> _buildItems(BuildContext context) {
    List<DropdownMenuItem<String>> ret = <DropdownMenuItem<String>>[];
    ret.add(
      new DropdownMenuItem<String>(
        child: new Text(Messages.of(context).noclub),
        value: noClub,
      ),
    );
    UserDatabaseData.instance.clubs.forEach((String key, Club club) {
      if (adminOnly && club.isAdmin()) {
        ret.add(
          new DropdownMenuItem<String>(
            child: new Text(club.name),
            value: club.uid,
          ),
        );
      }
    });
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return new InputDecorator(
      decoration: new InputDecoration(
        labelText: Messages.of(context).club,
        labelStyle: selectedTitle
            ? Theme
                .of(context)
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
            child: new DropdownButton<String>(
              hint: new Text(Messages.of(context).selectclub),
              items: _buildItems(context),
              value: clubUid,
              onChanged: (String val) {
                onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
