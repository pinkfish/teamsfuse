import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// The icon to display for the attendence.
///
class AttendanceIcon extends StatelessWidget {
  /// Constructor.
  AttendanceIcon(this.attend);

  /// The current attendence to display.
  final Attendance attend;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (attend != null) {
      switch (attend) {
        case Attendance.Yes:
          return Icon(Icons.check, color: theme.accentColor);
          break;
        case Attendance.No:
          return Icon(Icons.clear, color: theme.errorColor);
          break;
        case Attendance.Maybe:
          return Icon(Icons.help, color: theme.disabledColor);
          break;
      }
    }
    return Icon(Icons.help, color: theme.disabledColor);
  }
}
