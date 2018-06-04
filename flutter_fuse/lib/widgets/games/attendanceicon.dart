import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

class AttendanceIcon extends StatelessWidget {
  final Attendance attend;

  AttendanceIcon(this.attend);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (attend != null) {
      switch (attend) {
        case Attendance.Yes:
          return new Icon(Icons.check, color: theme.accentColor);
          break;
        case Attendance.No:
          return new Icon(Icons.clear, color: theme.errorColor);
          break;
        case Attendance.Maybe:
          return new Icon(Icons.help, color: theme.disabledColor);
          break;
      }
    }
    return new Icon(Icons.help, color: theme.disabledColor);
  }
}
