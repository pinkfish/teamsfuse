import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class AttendanceDialog extends StatefulWidget {
  AttendanceDialog({this.current});

  final Attendance current;

  @override
  AttendanceDialogState createState() {
    return AttendanceDialogState();
  }
}

class AttendanceDialogState extends State<AttendanceDialog> {
  AttendanceDialogState();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
