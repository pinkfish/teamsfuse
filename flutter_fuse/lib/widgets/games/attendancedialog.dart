import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';

class AttendanceDialog extends StatefulWidget {
  final Attendance current;
  AttendanceDialog({this.current});

  @override
  AttendanceDialogState createState() {
    return new AttendanceDialogState();
  }
}

class AttendanceDialogState extends State<AttendanceDialog> {
  AttendanceDialogState();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return new SimpleDialog(
      title: new Text(Messages.of(context).attendanceselect),
      children: <Widget>[
        new SimpleDialogOption(
          child: new ListTile(
            leading: new Icon(Icons.check, color: theme.accentColor),
            title: new Text(Messages.of(context).attendanceyes),
            dense: true,
            selected: widget.current == Attendance.Yes,
          ),
          onPressed: () {
            Navigator.pop(context, Attendance.Yes);
          },
        ),
        new Divider(),
        new SimpleDialogOption(
          child: new ListTile(
            leading: new Icon(Icons.clear, color: theme.errorColor),
            title: new Text(Messages.of(context).attendanceno),
            dense: true,
            selected: widget.current == Attendance.No,
          ),
          onPressed: () {
            Navigator.pop(context, Attendance.No);
          },
        ),
        new Divider(),
        new SimpleDialogOption(
          child: new ListTile(
            leading: new Icon(Icons.help, color: theme.disabledColor),
            title: new Text(Messages.of(context).attendncemaybe),
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
