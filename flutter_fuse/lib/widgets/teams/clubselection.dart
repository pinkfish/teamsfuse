import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../form/clubpicker.dart';

///
/// Selects the club to use for adding a game/event/whatever.
///
class ClubSelection extends StatefulWidget {
  /// Constructor.
  ClubSelection({@required this.onChanged, @required this.initialClub});

  /// Called when the value changes.
  final ValueChanged<Club> onChanged;

  /// The initialTeam
  final Club initialClub;

  @override
  _ClubSelectionState createState() {
    return _ClubSelectionState();
  }
}

class _ClubSelectionState extends State<ClubSelection> {
  String _clubUid;

  void _updateClub(String clubUid) {
    setState(() {
      if (clubUid == ClubPicker.noClub) {
        _clubUid = null;
        widget.onChanged(null);
      } else {
        _clubUid = clubUid;
        var bloc = BlocProvider.of<ClubBloc>(context);
        widget.onChanged(bloc.state.clubs[_clubUid]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    print('$_clubUid');
    widgets.add(
      ClubPicker(
        onChanged: _updateClub,
        clubUid: _clubUid ?? ClubPicker.noClub,
        selectedTitle: _clubUid != null,
      ),
    );

    return DropdownButtonHideUnderline(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }
}
