import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Shows multiple attendance players and sets the attendance for all of them.
///
class MultipleAttendanceDialog extends StatefulWidget {
  /// Constructor.
  MultipleAttendanceDialog(this.attendance);

  /// The attendence map to update.
  final Map<Player, Attendance> attendance;

  @override
  _MultipleAttendanceDialogState createState() {
    return _MultipleAttendanceDialogState();
  }
}

class _MultipleAttendanceDialogState extends State<MultipleAttendanceDialog> {
  final Map<Player, Attendance> _updatedAttendance = <Player, Attendance>{};

  List<Widget> _buildAttendenceSet(BuildContext context) {
    var ret = <Widget>[];

    var theme = Theme.of(context);
    var selected = BoxDecoration(
      color: theme.highlightColor,
    );

    for (var data in widget.attendance.entries) {
      var player = data.key;
      var attend = data.value;
      if (_updatedAttendance.containsKey(player)) {
        attend = _updatedAttendance[player];
      }
      ret.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text(player.name)),
            Container(
              width: 150.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    decoration: (attend == Attendance.Yes ? selected : null),
                    child: IconButton(
                      iconSize: 24.0,
                      onPressed: () {
                        setState(() {
                          _updatedAttendance[player] = Attendance.Yes;
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.check, color: theme.accentColor),
                    ),
                  ),
                  Container(
                    decoration: (attend == Attendance.No ? selected : null),
                    child: IconButton(
                      iconSize: 24.0,
                      onPressed: () {
                        setState(() {
                          _updatedAttendance[player] = Attendance.No;
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.clear, color: theme.errorColor),
                    ),
                  ),
                  Container(
                    decoration: (attend == Attendance.Maybe ? selected : null),
                    child: IconButton(
                      iconSize: 24.0,
                      onPressed: () {
                        setState(() {
                          _updatedAttendance[player] = Attendance.Maybe;
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.help, color: theme.disabledColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ret;
  }

  void _saveDialog() {
    if (_updatedAttendance.length == 0) {
      // nothing.
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context, _updatedAttendance);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: IntrinsicWidth(
        stepWidth: 56.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.headline6,
                    child: Text(Messages.of(context).attendanceselect)),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 12.0, 0.0, 16.0),
                  child: ListBody(children: _buildAttendenceSet(context)),
                ),
              ),
              FlatButton(
                  onPressed: _saveDialog,
                  child: Text(Messages.of(context).saveButtonText))
            ],
          ),
        ),
      ),
    );
  }
}
