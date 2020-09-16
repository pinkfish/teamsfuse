import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/form/clubpicker.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Selects the team to use for adding a game/event/whatever.  Will select
/// between clubs/teams/leagues.
///
class ClubSelection extends StatefulWidget {
  ClubSelection({@required this.onChanged, @required this.initialClub});

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
        ClubBloc bloc = BlocProvider.of<ClubBloc>(context);
        widget.onChanged(bloc.state.clubs[_clubUid]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
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
