import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/clubteampicker.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleclubprovider.dart';
import 'teamtile.dart';

///
/// Selects the team to use for adding a game/event/whatever.  Will select
/// between clubs/teams/leagues.
///
class TeamSelection extends StatefulWidget {
  TeamSelection(
      {@required this.onChanged,
      @required this.initialTeam,
      @required this.club});

  final ValueChanged<Team> onChanged;

  /// The initialTeam
  final Team initialTeam;

  final Club club;

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
                  style: Theme.of(context)
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
    TeamBloc bloc = BlocProvider.of<TeamBloc>(context);
    List<Widget> widgets = <Widget>[];
    print('$_clubUid');
    if (widget.club == null) {
      widgets.add(
        new TeamPicker(
          onChanged: (String str) =>
              _teamChanged(bloc.currentState.getTeam(str)),
          teamUid: _team?.uid,
          disabled: _clubUid != null,
          selectedTitle: _team != null,
        ),
      );
    } else {
      widgets.add(
        SingleClubProvider(
          clubUid: widget.club.uid,
          builder: (BuildContext context, SingleClubBloc bloc) =>
              ClubTeamPicker(
                onChanged: _teamChanged,
                team: _team,
                clubBloc: bloc,
              ),
        ),
      );
    }
    widgets.addAll(
      <Widget>[
        new SizedBox(height: 20.0),
        new Text(
          Messages.of(context).teamselected,
          style: Theme.of(context).textTheme.subhead.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).accentColor),
        ),
        _buildCurrentTeam(context),
      ],
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
