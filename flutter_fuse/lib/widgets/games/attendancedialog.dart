import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Show a dialog to set the attendance for this game/item.
///
class AttendanceDialog extends StatefulWidget {
  /// Constructor.
  AttendanceDialog({this.current});

  /// The current attendence setup.
  final Attendance current;

  @override
  _AttendanceDialogState createState() {
    return _AttendanceDialogState();
  }
}

///
/// The state to track for the attendance.
///
class _AttendanceDialogState extends State<AttendanceDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SimpleDialog(
      title: Text(Messages.of(context).attendanceselect),
      children: <Widget>[
        SimpleDialogOption(
          child: ListTile(
            leading: Icon(Icons.check, color: theme.accentColor),
            title: Text(Messages.of(context).attendanceyes),
            dense: true,
            selected: widget.current == Attendance.Yes,
          ),
          onPressed: () {
            Navigator.pop(context, Attendance.Yes);
          },
        ),
        Divider(),
        SimpleDialogOption(
          child: ListTile(
            leading: Icon(Icons.clear, color: theme.errorColor),
            title: Text(Messages.of(context).attendanceno),
            dense: true,
            selected: widget.current == Attendance.No,
          ),
          onPressed: () {
            Navigator.pop(context, Attendance.No);
          },
        ),
        Divider(),
        SimpleDialogOption(
          child: ListTile(
            leading: Icon(Icons.help, color: theme.disabledColor),
            title: Text(Messages.of(context).attendncemaybe),
            dense: true,
            selected: widget.current == Attendance.Maybe,
          ),
          onPressed: () {
            Navigator.pop(context, Attendance.Maybe);
          },
        )
      ],
    );
  }
}
