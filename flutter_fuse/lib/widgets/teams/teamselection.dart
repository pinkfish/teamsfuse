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

  final Club club;

  TeamSelection(
      {@required this.onChanged,
      @required this.initialTeam,
      @required this.club});

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
                title: new Text(
                  Messages.of(context).team,
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption
                      .copyWith(color: Theme.of(context).hintColor),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    print('$_clubUid');
    if (widget.club == null) {
      widgets.add(
        new TeamPicker(
          onChanged: (String str) =>
              _teamChanged(UserDatabaseData.instance.teams[str]),
          teamUid: _team?.uid,
          disabled: _clubUid != null,
          selectedTitle: _team != null,
        ),
      );
    } else {
      widgets.add(new ClubTeamPicker(
        onChanged: _teamChanged,
        team: _team,
        clubUid: widget.club.uid,
      ));
    }
    widgets.addAll([
      new SizedBox(height: 20.0),
      new Text(
        Messages.of(context).teamselected,
        style: Theme.of(context).textTheme.subhead.copyWith(
            fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
      ),
      _buildCurrentTeam(context),
    ]);
    return new DropdownButtonHideUnderline(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }
}
