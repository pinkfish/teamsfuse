import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'teamtile.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/clubpicker.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/form/clubteampicker.dart';

///
/// Selects the team to use for adding a game/event/whatever.  Will select
/// between clubs/teams/leagues.
///
class TeamSelection extends StatefulWidget {
  final ValueChanged<Team> onChanged;

  /// The initialTeam
  final Team initialTeam;

  TeamSelection({@required this.onChanged, @required this.initialTeam});

  @override
  _TeamSelectionState createState() {
    return new _TeamSelectionState();
  }
}

class _TeamSelectionState extends State<TeamSelection> {
  String _clubUid;
  Team _team;

  @override
  void initState() {
    _team = widget.initialTeam;
    super.initState();
  }

  Widget _buildCurrentTeam(BuildContext context) {
    if (_team == null) {
      return new Row(
        children: <Widget>[
          new Expanded(
            child: new Card(
              child: new ListTile(
                  title: new Text(Messages.of(context).teamselect)),
            ),
          )
        ],
      );
    }
    return new Card(
      child: new TeamTile(_team),
    );
  }

  void _teamChanged(Team team) {
    _team = team;
    widget.onChanged(team);
  }

  void _updateClub(String clubUid) {
    setState(() {
      if (clubUid == ClubPicker.noClub) {
        _clubUid = null;
      } else {
        _clubUid = clubUid;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new DropdownButtonHideUnderline(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildCurrentTeam(context),
          new TeamPicker(
            onChanged: (String str) =>
                _teamChanged(UserDatabaseData.instance.teams[str]),
            teamUid: _team?.uid,
            disabled: _clubUid != null,
          ),
          new ClubPicker(
            onChanged: _updateClub,
            clubUid: _clubUid,
          ),
          new ClubTeamPicker(
            onChanged: _teamChanged,
            team: _team,
            clubUid: _clubUid,
          )
        ],
      ),
    );
  }
}
