import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class MultipleAttendanceDialog extends StatefulWidget {
  MultipleAttendanceDialog(this.attendance);

  final Map<Player, Attendance> attendance;

  @override
  MultipleAttendanceDialogState createState() {
    return MultipleAttendanceDialogState(
        Map<Player, Attendance>.from(attendance));
  }
}

class MultipleAttendanceDialogState extends State<MultipleAttendanceDialog> {
  MultipleAttendanceDialogState(this._attendance);

  Map<Player, Attendance> _attendance;
  Set<Player> _changed = Set<Player>();

  List<Widget> _buildAttendenceSet(BuildContext context) {
    List<Widget> ret = <Widget>[];

    ThemeData theme = Theme.of(context);
    BoxDecoration selected = BoxDecoration(
      color: theme.highlightColor,
    );

    _attendance.forEach((Player player, Attendance attend) {
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
                          _attendance[player] = Attendance.Yes;
                          _changed.add(player);
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
                          _attendance[player] = Attendance.No;
                          _changed.add(player);
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
                          _attendance[player] = Attendance.Maybe;
                          _changed.add(player);
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
    });

    return ret;
  }

  void _saveDialog() {
    if (_changed.length == 0) {
      // nothing.
      Navigator.pop(context);
      return;
    }
    Map<Player, Attendance> ret = <Player, Attendance>{};
    _changed.forEach((Player player) {
      ret[player] = _attendance[player];
    });
    Navigator.pop(context, ret);
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
                    style: Theme.of(context).textTheme.title,
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
                  child: Text(Messages.of(context).savebuttontext))
            ],
          ),
        ),
      ),
    );
  }
}
