import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Show the filter options for the home of the app.
///
class FilterHomeDialog extends StatefulWidget {
  /// Constructor.
  FilterHomeDialog(this.details);

  /// The current filter details.
  final FilterDetails details;

  @override
  _FilterHomeDialogState createState() {
    return _FilterHomeDialogState();
  }
}

class _FilterHomeDialogState extends State<FilterHomeDialog> {
  void _openTeamListWithCheckbox() {
    var messages = Messages.of(context);
    var teams = <Widget>[];
    var teamBloc = BlocProvider.of<TeamBloc>(context);

    for (var uid in teamBloc.state.allTeamUids) {
      var team = teamBloc.state.getTeam(uid);
      var isOn = widget.details.teamUids.contains(uid);
      teams.add(_CheckboxDialogItem(
          initialValue: isOn,
          title: team.name,
          onChanged: (val) => val
              ? widget.details.teamUids.add(uid)
              : widget.details.teamUids.remove(uid)));
    }
    teams.add(ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ));
    showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(messages.teamselect),
          children: teams,
        );
      },
    ).then((closed) {
      setState(() {});
    });
  }

  Widget _showTeamPicker() {
    var messages = Messages.of(context);
    var pickerText = '';
    if (widget.details.teamUids.isEmpty) {
      pickerText = messages.allteams;
    } else {
      var teamBloc = BlocProvider.of<TeamBloc>(context);
      pickerText = widget.details.teamUids
          .map((uid) => teamBloc.state.getTeam(uid).name)
          .join((', '));
    }
    return InkWell(
      onTap: _openTeamListWithCheckbox,
      child: Row(
        children: <Widget>[
          Text(pickerText),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
    );
  }

  void _openPlayerListWithCheckbox() {
    var messages = Messages.of(context);
    var players = <Widget>[];
    var playerBloc = BlocProvider.of<PlayerBloc>(context);

    for (var uid in playerBloc.state.players.keys) {
      var player = playerBloc.state.getPlayer(uid);
      var isOn = widget.details.playerUids.contains(uid);
      players.add(_CheckboxDialogItem(
          initialValue: isOn,
          title: player.name,
          onChanged: (val) => val
              ? widget.details.playerUids.add(uid)
              : widget.details.playerUids.remove(uid)));
    }
    players.add(ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ));
    showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(messages.playerselect),
          children: players,
        );
      },
    ).then((closed) {
      setState(() {});
    });
    ;
  }

  Widget _showPlayerPicker() {
    var messages = Messages.of(context);
    var pickerText = '';
    if (widget.details.playerUids.isEmpty) {
      pickerText = messages.everyone;
    } else {
      var playerBloc = BlocProvider.of<PlayerBloc>(context);

      pickerText = widget.details.playerUids
          .map((uid) => playerBloc.state.getPlayer(uid).name)
          .join((', '));
    }
    return InkWell(
      onTap: _openPlayerListWithCheckbox,
      child: Row(
        children: <Widget>[
          Text(pickerText),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(messages.title),
        actions: const <Widget>[],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.check),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Open up a drop down with checkboxes for teams.
            ListTile(
              leading: const Icon(Icons.people),
              title: _showTeamPicker(),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: _showPlayerPicker(),
            ),
            ListTile(
              leading: const Icon(Icons.gamepad),
              title: DropdownButton<GameResult>(
                value: widget.details.result,
                items: <DropdownMenuItem<GameResult>>[
                  DropdownMenuItem<GameResult>(
                    value: null,
                    child: Text(messages.noresult),
                  ),
                  DropdownMenuItem<GameResult>(
                    value: GameResult.Win,
                    child: Text(messages.win),
                  ),
                  DropdownMenuItem<GameResult>(
                    value: GameResult.Loss,
                    child: Text(messages.loss),
                  ),
                  DropdownMenuItem<GameResult>(
                    value: GameResult.Tie,
                    child: Text(messages.tie),
                  ),
                  DropdownMenuItem<GameResult>(
                    value: GameResult.Unknown,
                    child: Text(messages.notFinished),
                  ),
                ],
                onChanged: (res) {
                  setState(() {
                    widget.details.result = res;
                  });
                },
              ),
            ),
            ListTile(
              leading: const Icon(MdiIcons.tshirtCrew),
              title: DropdownButton<EventType>(
                value: widget.details.eventType,
                items: <DropdownMenuItem<EventType>>[
                  DropdownMenuItem<EventType>(
                    value: null,
                    child: Text(messages.noevent),
                  ),
                  DropdownMenuItem<EventType>(
                    value: EventType.Game,
                    child: Text(messages.gametype),
                  ),
                  DropdownMenuItem<EventType>(
                    value: EventType.Practice,
                    child: Text(messages.trainingtype),
                  ),
                  DropdownMenuItem<EventType>(
                    value: EventType.Event,
                    child: Text(messages.eventtype),
                  ),
                ],
                onChanged: (ev) {
                  setState(() {
                    widget.details.eventType = ev;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxDialogItem extends StatefulWidget {
  _CheckboxDialogItem({this.initialValue = false, this.onChanged, this.title});

  final ValueChanged<bool> onChanged;
  final bool initialValue;
  final String title;

  @override
  State createState() {
    return _CheckboxDialogItemState();
  }
}

class _CheckboxDialogItemState extends State<_CheckboxDialogItem> {
  bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: _isOn,
        onChanged: (val) => setState(() {
          _isOn = val;
          widget.onChanged(val);
        }),
      ),
      title: Text(widget.title),
    );
  }
}
