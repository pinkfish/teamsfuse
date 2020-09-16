import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class FilterHomeDialog extends StatefulWidget {
  FilterHomeDialog(this.details);

  final FilterDetails details;

  @override
  _FilterHomeDialogState createState() {
    return _FilterHomeDialogState();
  }
}

class _FilterHomeDialogState extends State<FilterHomeDialog> {
  void _openTeamListWithCheckbox() {
    Messages messages = Messages.of(context);
    List<Widget> teams = <Widget>[];
    TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);

    for (String uid in teamBloc.state.allTeamUids) {
      Team team = teamBloc.state.getTeam(uid);
      bool isOn = widget.details.teamUids.contains(uid);
      teams.add(_CheckboxDialogItem(
          initialValue: isOn,
          title: team.name,
          onChanged: (bool val) => val
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
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(messages.teamselect),
          children: teams,
        );
      },
    ).then((bool closed) {
      setState(() {});
    });
  }

  Widget _showTeamPicker() {
    Messages messages = Messages.of(context);
    String pickerText = "";
    if (widget.details.teamUids.length == 0) {
      pickerText = messages.allteams;
    } else {
      TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
      pickerText = widget.details.teamUids
          .map((String uid) => teamBloc.state.getTeam(uid).name)
          .join((", "));
    }
    return InkWell(
      child: Row(
        children: <Widget>[
          Text(pickerText),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
      onTap: _openTeamListWithCheckbox,
    );
  }

  void _openPlayerListWithCheckbox() {
    Messages messages = Messages.of(context);
    List<Widget> players = <Widget>[];
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);

    for (String uid in playerBloc.state.players.keys) {
      Player player = playerBloc.state.getPlayer(uid);
      bool isOn = widget.details.playerUids.contains(uid);
      players.add(_CheckboxDialogItem(
          initialValue: isOn,
          title: player.name,
          onChanged: (bool val) => val
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
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(messages.playerselect),
          children: players,
        );
      },
    ).then((bool closed) {
      setState(() {});
    });
    ;
  }

  Widget _showPlayerPicker() {
    Messages messages = Messages.of(context);
    String pickerText = "";
    if (widget.details.playerUids.length == 0) {
      pickerText = messages.everyone;
    } else {
      PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);

      pickerText = widget.details.playerUids
          .map((String uid) => playerBloc.state.getPlayer(uid).name)
          .join((", "));
    }
    return InkWell(
      child: Row(
        children: <Widget>[
          Text(pickerText),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
      onTap: _openPlayerListWithCheckbox,
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

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
                    child: Text(messages.noresult),
                    value: null,
                  ),
                  DropdownMenuItem<GameResult>(
                    child: Text(messages.win),
                    value: GameResult.Win,
                  ),
                  DropdownMenuItem<GameResult>(
                    child: Text(messages.loss),
                    value: GameResult.Loss,
                  ),
                  DropdownMenuItem<GameResult>(
                    child: Text(messages.tie),
                    value: GameResult.Tie,
                  ),
                  DropdownMenuItem<GameResult>(
                    child: Text(messages.notfinished),
                    value: GameResult.Unknown,
                  ),
                ],
                onChanged: (GameResult res) {
                  setState(() {
                    widget.details.result = res;
                  });
                },
              ),
            ),
            ListTile(
              leading: const Icon(CommunityIcons.tshirtCrew),
              title: DropdownButton<EventType>(
                value: widget.details.eventType,
                items: <DropdownMenuItem<EventType>>[
                  DropdownMenuItem<EventType>(
                    child: Text(messages.noevent),
                    value: null,
                  ),
                  DropdownMenuItem<EventType>(
                    child: Text(messages.gametype),
                    value: EventType.Game,
                  ),
                  DropdownMenuItem<EventType>(
                    child: Text(messages.trainingtype),
                    value: EventType.Practice,
                  ),
                  DropdownMenuItem<EventType>(
                    child: Text(messages.eventtype),
                    value: EventType.Event,
                  ),
                ],
                onChanged: (EventType ev) {
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
        onChanged: (bool val) => setState(() {
          _isOn = val;
          widget.onChanged(val);
        }),
      ),
      title: Text(widget.title),
    );
  }
}
