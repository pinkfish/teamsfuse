import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/clubpicker.dart';

///
/// Selects the team to use for adding a game/event/whatever.  Will select
/// between clubs/teams/leagues.
///
class ClubSelection extends StatefulWidget {
  final ValueChanged<Club> onChanged;

  /// The initialTeam
  final Club initialClub;

  ClubSelection({@required this.onChanged, @required this.initialClub});

  @override
  _ClubSelectionState createState() {
    return new _ClubSelectionState();
  }
}

class _ClubSelectionState extends State<ClubSelection> {
  String _clubUid;

  @override
  void initState() {
    super.initState();
  }

  void _updateClub(String clubUid) {
    setState(() {
      if (clubUid == ClubPicker.noClub) {
        _clubUid = null;
        widget.onChanged(null);
      } else {
        _clubUid = clubUid;
        widget.onChanged(UserDatabaseData.instance.clubs[_clubUid]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    print('$_clubUid');
    widgets.add(
      new ClubPicker(
        onChanged: _updateClub,
        clubUid: _clubUid ?? ClubPicker.noClub,
        selectedTitle: _clubUid != null,
      ),
    );

    return new DropdownButtonHideUnderline(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }
}
