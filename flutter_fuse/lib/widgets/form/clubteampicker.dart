import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// The picker for the team in the club.
///
class ClubTeamPicker extends StatefulWidget {
  /// Constructor.
  ClubTeamPicker({
    @required this.onChanged,
    @required this.clubBloc,
    this.team,
    this.selectedTitle = false,
  });

  /// The callback is onChanged.
  final ValueChanged<Team> onChanged;

  /// The club bloc to get the details from.
  final SingleClubBloc clubBloc;

  /// The team currently selected.
  final Team team;

  /// If the title is selected.
  final bool selectedTitle;

  @override
  _ClubTeamPickerState createState() {
    return _ClubTeamPickerState();
  }
}

class _ClubTeamPickerState extends State<ClubTeamPicker> {
  _ClubTeamPickerState() {
    widget.clubBloc.add(SingleClubLoadTeams(false));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshClub();
  }

  void _refreshClub() {}

  @override
  void didUpdateWidget(ClubTeamPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshClub();
  }

  List<DropdownMenuItem<Team>> _buildItems(SingleClubState state) {
    var ret = <DropdownMenuItem<Team>>[];
    if (state.teams.length != 0) {
      print('Teams..');
      var sorted = state.teams.toList();
      sorted.sort();
      for (var teamDrop in sorted) {
        ret.add(DropdownMenuItem<Team>(
          child: Text(teamDrop.name),
          value: teamDrop,
        ));
      }
    }
    print('$ret');
    return ret;
  }

  Widget _buildDecorator(Widget inner) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: Messages.of(context).team,
        labelStyle: widget.selectedTitle
            ? Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(flex: 1, child: inner),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clubBloc == null) {
      Widget inner = ListTile(
        //trailing: const Icon(CommunityIcons.update),
        title: Text(
          Messages.of(context).selectclub,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(color: Theme.of(context).disabledColor),
        ),
      );
      return _buildDecorator(inner);
    } else {
      return BlocBuilder(
        cubit: widget.clubBloc,
        builder: (context, state) {
          Widget inner;

          if (state.teams.length == 0) {
            inner = ListTile(
              leading: CircularProgressIndicator(),
              title: Text(
                Messages.of(context).loading,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            );
          } else {
            inner = DropdownButton<Team>(
              hint: Text(Messages.of(context).teamselect),
              items: _buildItems(state),
              value: widget.team,
              onChanged: (val) {
                widget.onChanged(val);
              },
            );
          }
          return _buildDecorator(inner);
        },
      );
    }
  }
}
