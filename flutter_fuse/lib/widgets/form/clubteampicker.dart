import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubTeamPicker extends StatefulWidget {
  ClubTeamPicker({
    @required this.onChanged,
    @required this.clubBloc,
    this.team,
    this.selectedTitle = false,
  });

  final ValueChanged<Team> onChanged;
  final SingleClubBloc clubBloc;
  final Team team;
  final bool selectedTitle;

  @override
  ClubTeamPickerState createState() {
    return new ClubTeamPickerState();
  }
}

class ClubTeamPickerState extends State<ClubTeamPicker> {
  ClubTeamPickerState() {
    widget.clubBloc.dispatch(SingleClubLoadTeams());
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
    List<DropdownMenuItem<Team>> ret = <DropdownMenuItem<Team>>[];
    if (state.teams.length != 0) {
      print('Teams..');
      List<Team> sorted = state.teams.toList();
      sorted.sort();
      for (Team teamDrop in sorted) {
        ret.add(new DropdownMenuItem<Team>(
          child: new Text(teamDrop.name),
          value: teamDrop,
        ));
      }
    }
    print('$ret');
    return ret;
  }

  Widget _buildDecorator(Widget inner) {
    return new InputDecorator(
      decoration: new InputDecoration(
        labelText: Messages.of(context).team,
        labelStyle: widget.selectedTitle
            ? Theme.of(context)
                .textTheme
                .subhead
                .copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(flex: 1, child: inner),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clubBloc == null) {
      Widget inner = new ListTile(
        //trailing: const Icon(CommunityIcons.update),
        title: new Text(
          Messages.of(context).selectclub,
          style: Theme.of(context)
              .textTheme
              .body1
              .copyWith(color: Theme.of(context).disabledColor),
        ),
      );
      return _buildDecorator(inner);
    } else {
      return BlocBuilder(
        bloc: widget.clubBloc,
        builder: (BuildContext context, SingleClubState state) {
          Widget inner;

          if (state.teams.length == 0) {
            inner = ListTile(
              leading: new CircularProgressIndicator(),
              title: new Text(
                Messages.of(context).loading,
                style: Theme.of(context).textTheme.body1,
              ),
            );
          } else {
            inner = new DropdownButton<Team>(
              hint: new Text(Messages.of(context).teamselect),
              items: _buildItems(state),
              value: widget.team,
              onChanged: (Team val) {
                widget.onChanged(val);
              },
            );
            return _buildDecorator(inner);
          }
        },
      );
    }
  }
}
