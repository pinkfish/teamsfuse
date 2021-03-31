import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleclubprovider.dart';
import '../form/clubteampicker.dart';
import '../form/teampicker.dart';
import 'teamtile.dart';

///
/// Selects the team to use for adding a game/event/whatever.  Will select
/// between clubs/teams/leagues.
///
class TeamSelection extends StatefulWidget {
  /// The constrctor.
  TeamSelection(
      {@required this.onChanged,
      @required this.initialTeam,
      @required this.club});

  /// Called when the team selection is changed.
  final ValueChanged<Team> onChanged;

  /// The initialTeam
  final Team initialTeam;

  /// The club to use to find teams in.
  final Club club;

  @override
  _TeamSelectionState createState() {
    return _TeamSelectionState();
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
      return Row(
        children: <Widget>[
          Expanded(
            child: Card(
              child: ListTile(
                title: Text(
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
    return Card(
      child: TeamTile(_team.uid),
    );
  }

  void _teamChanged(Team team) {
    setState(() => _team = team);
    widget.onChanged(team);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<TeamBloc>(context);
    var widgets = <Widget>[];
    if (widget.club == null) {
      widgets.add(
        TeamPicker(
          onChanged: (str) => _teamChanged(bloc.state.getTeam(str)),
          teamUid: _team?.uid,
          disabled: _clubUid != null,
          selectedTitle: _team != null,
        ),
      );
    } else {
      widgets.add(
        SingleClubProvider(
          clubUid: widget.club.uid,
          builder: (context, bloc) => ClubTeamPicker(
            onChanged: _teamChanged,
            team: _team,
            clubBloc: bloc,
          ),
        ),
      );
    }
    widgets.addAll(
      <Widget>[
        SizedBox(height: 20.0),
        Text(
          Messages.of(context).teamSelected,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).accentColor),
        ),
        _buildCurrentTeam(context),
      ],
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
