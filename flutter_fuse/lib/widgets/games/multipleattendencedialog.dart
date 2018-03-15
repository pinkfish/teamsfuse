import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';

class MultipleAttendanceDialog extends StatefulWidget {
  Map<Player, Attendance> attendance;
  MultipleAttendanceDialog(this.attendance);

  @override
  MultipleAttendanceDialogState createState() {
    return new MultipleAttendanceDialogState(
        new Map<Player, Attendance>.from(attendance));
  }
}

class MultipleAttendanceDialogState extends State<MultipleAttendanceDialog> {
  Map<Player, Attendance> _attendance;
  Set<Player> _changed = new Set<Player>();
  Game _game;

  MultipleAttendanceDialogState(this._attendance);

  List<Widget> _buildAttendenceSet(BuildContext context) {
    List<Widget> ret = new List<Widget>();

    ThemeData theme = Theme.of(context);
    BoxDecoration selected = new BoxDecoration(
      color: theme.highlightColor,
    );

    _attendance.forEach((Player player, Attendance attend) {
      ret.add(
        new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Expanded(child: new Text(player.name)),
            new Container(
              width: 150.0,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Container(
                    decoration: (attend == Attendance.Yes ? selected : null),
                    child: new IconButton(
                      iconSize: 24.0,
                      onPressed: () {
                        setState(() {
                          _attendance[player] = Attendance.Yes;
                          _changed.add(player);
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: new Icon(Icons.check, color: theme.accentColor),
                    ),
                  ),
                  new Container(
                    decoration: (attend == Attendance.No ? selected : null),
                    child: new IconButton(
                      iconSize: 24.0,
                      onPressed: () {
                        setState(() {
                          _attendance[player] = Attendance.No;
                          _changed.add(player);
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: new Icon(Icons.clear, color: theme.errorColor),
                    ),
                  ),
                  new Container(
                    decoration: (attend == Attendance.Maybe ? selected : null),
                    child: new IconButton(
                      iconSize: 24.0,
                      onPressed: () {
                        setState(() {
                          _attendance[player] = Attendance.Maybe;
                          _changed.add(player);
                        });
                      },
                      padding: EdgeInsets.zero,
                      icon: new Icon(Icons.help, color: theme.disabledColor),
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
    Map<Player, Attendance> ret = new Map<Player, Attendance>();
    _changed.forEach((Player player) {
      ret[player] = _attendance[player];
    });
    Navigator.pop(context, ret);
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: new IntrinsicWidth(
        stepWidth: 56.0,
        child: new ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              new Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                child: new DefaultTextStyle(
                    style: Theme.of(context).textTheme.title,
                    child: new Text(Messages.of(context).attendanceselect)),
              ),
              new Flexible(
                child: new SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 12.0, 0.0, 16.0),
                  child:
                      new ListBody(children: this._buildAttendenceSet(context)),
                ),
              ),
              new FlatButton(
                  onPressed: this._saveDialog,
                  child: new Text(Messages.of(context).savebuttontext))
            ],
          ),
        ),
      ),
    );
  }
}
