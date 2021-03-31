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
      title: Text(Messages.of(context).attendanceSelect),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, Attendance.Yes);
          },
          child: ListTile(
            leading: Icon(Icons.check, color: theme.accentColor),
            title: Text(Messages.of(context).attendanceYes),
            dense: true,
            selected: widget.current == Attendance.Yes,
          ),
        ),
        Divider(),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, Attendance.No);
          },
          child: ListTile(
            leading: Icon(Icons.clear, color: theme.errorColor),
            title: Text(Messages.of(context).attendanceNo),
            dense: true,
            selected: widget.current == Attendance.No,
          ),
        ),
        Divider(),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, Attendance.Maybe);
          },
          child: ListTile(
            leading: Icon(Icons.help, color: theme.disabledColor),
            title: Text(Messages.of(context).attendnceMaybe),
            dense: true,
            selected: widget.current == Attendance.Maybe,
          ),
        )
      ],
    );
  }
}
