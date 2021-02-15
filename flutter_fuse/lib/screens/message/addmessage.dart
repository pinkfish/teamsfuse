import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/form/seasonformfield.dart';
import '../../widgets/form/teampicker.dart';
import '../../widgets/player/playername.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Adds a message to one of the players/users in the team.
///
class AddMessageScreen extends StatefulWidget {
  /// Constructor.
  AddMessageScreen({this.teamUid, this.seasonUid, this.playerUid});

  /// The team the user is in.
  final String teamUid;

  /// The season the user is in.
  final String seasonUid;

  /// The player to send the message too.
  final String playerUid;

  @override
  _AddMessageScreenState createState() {
    return _AddMessageScreenState();
  }
}

class _AddMessageScreenState extends State<AddMessageScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _seasonUid;
  String _sendAs;
  final List<String> _possiblePlayers = <String>[];
  bool _allPlayers = true;
  bool _includeMyself = false;
  final FocusNode _focusNodeSubject = FocusNode();
  final FocusNode _focusNodeBody = FocusNode();
  TeamBloc _teamBloc;
  SeasonBloc _seasonBloc;
  String _messageBody;
  AddMessageBloc addMessageBloc;
  String _teamUid;
  final Set<String> _recipients = <String>{};
  String _subject;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _teamBloc = BlocProvider.of<TeamBloc>(context);
    _seasonBloc = BlocProvider.of<SeasonBloc>(context);

    _teamUid = widget.teamUid;
    _seasonUid = widget.seasonUid;
    addMessageBloc = AddMessageBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));

    if (widget.playerUid != null) {
      _recipients.add(widget.playerUid);
    } else {
      _recipients.clear();
    }
  }

  void _changeTeam(String teamUid) {
    if (teamUid != _teamUid) {
      setState(() {
        _teamUid = teamUid;
        _seasonUid = _teamBloc.state.getTeam(teamUid).currentSeason;
      });
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _sendMessage() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_allPlayers) {
        // Add in everyone!
        for (var play in _seasonBloc.state.seasons[_seasonUid].players) {
          if (_includeMyself || play.playerUid != _sendAs) {
            _recipients.add(play.playerUid);
          }
        }
      }
      if (_recipients.length > 0) {
        addMessageBloc.add(AddMessageEventCommit(
            teamUid: _teamUid,
            recipients: _recipients,
            subject: _subject,
            body: _messageBody));
      } else {
        _showInSnackBar("Need to specify some recipients");
      }
    } else {
      _showInSnackBar(Messages.of(context).formerror);
      _autovalidateMode = AutovalidateMode.always;
    }
  }

  Widget _buildPlayerPicker() {
    var playerBloc = BlocProvider.of<PlayerBloc>(context);

    if (_teamUid != null) {
      return SingleTeamProvider(
        teamUid: _teamUid,
        builder: (context, singleTeamBloc) {
          var ret = <Widget>[];
          // Build the rest of the form.
          ret.add(
            SeasonFormField(
                teamBloc: singleTeamBloc,
                initialValue: _seasonUid,
                onSaved: (seasonUid) => _seasonUid = seasonUid),
          );
          if (_seasonUid != null &&
              _teamBloc.state.getTeam(_teamUid) != null &&
              _seasonBloc.state.seasons.containsKey(_seasonUid)) {
            // Show who we are sending as, drop down if there is more than one
            // option.
            if (_possiblePlayers.length > 1) {
              ret.add(
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: DropdownButton<String>(
                      value: _sendAs,
                      items: _possiblePlayers.map((str) {
                        var playerBloc = BlocProvider.of<PlayerBloc>(context);
                        return DropdownMenuItem<String>(
                            child: Text(playerBloc.state.players[str].name),
                            value: str);
                      }).toList(),
                      onChanged: (str) {
                        _sendAs = str;
                      }),
                ),
              );
            } else {
              _sendAs = playerBloc.state.me.uid;
              ret.add(
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(playerBloc.state.players[_sendAs]?.name ??
                      Messages.of(context).unknown),
                ),
              );
            }
            // Show the player selection details.
            ret.add(
              CheckboxListTile(
                secondary: const Icon(Icons.people),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _allPlayers,
                onChanged: (newVal) => setState(() => _allPlayers = newVal),
                title: Text(Messages.of(context).everyone),
              ),
            );
            if (_allPlayers) {
              ret.add(
                CheckboxListTile(
                  secondary: const Icon(Icons.person),
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: _includeMyself,
                  onChanged: (newVal) =>
                      setState(() => _includeMyself = newVal),
                  title: Text(Messages.of(context).includemyself),
                ),
              );
            } else {
              // Show the list of players with checkboxes.
              var season = _seasonBloc.state.seasons[_seasonUid];

              for (var player in season.players) {
                ret.add(
                  CheckboxListTile(
                    title: PlayerName(playerUid: player.playerUid),
                    subtitle:
                        Text(Messages.of(context).roleingame(player.role)),
                    value: _recipients.contains(player.playerUid),
                    onChanged: (toAdd) {
                      if (toAdd) {
                        _recipients.add(player.playerUid);
                      } else {
                        _recipients.remove(player.playerUid);
                      }
                    },
                  ),
                );
              }
            }
            // Add in the message box itself :)
            ret.add(
              EnsureVisibleWhenFocused(
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.subject),
                    labelText: Messages.of(context).subject,
                  ),
                  focusNode: _focusNodeSubject,
                  initialValue: _subject,
                  onSaved: (val) => _subject = val,
                ),
                focusNode: _focusNodeSubject,
              ),
            );
            ret.add(
              EnsureVisibleWhenFocused(
                focusNode: _focusNodeBody,
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.message),
                    labelText: Messages.of(context).message,
                  ),
                  focusNode: _focusNodeBody,
                  initialValue: _messageBody,
                  onSaved: (val) => _messageBody = val,
                  minLines: 3,
                  maxLines: 20,
                ),
              ),
            );
          }
          return Column(children: ret);
        },
      );
    }

    return SizedBox(width: 0, height: 0);
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(messages.title),
        actions: <Widget>[
          FlatButton(
            onPressed: _sendMessage,
            child: Text(
              Messages.of(context).sendmessagebuttontext,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocListener(
        cubit: addMessageBloc,
        listener: (context, state) {
          if (state is AddItemDone) {
            Navigator.pop(context);
          }
          if (state is AddItemSaveFailed || state is AddItemInvalidArguments) {
            _showInSnackBar(Messages.of(context).formerror);
          }
        },
        child: BlocBuilder(
          cubit: addMessageBloc,
          builder: (context, state) => SavingOverlay(
            saving: state is AddItemSaving,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: DropdownButtonHideUnderline(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(MdiIcons.tshirtCrew),
                          title: TeamPicker(
                            onChanged: _changeTeam,
                          ),
                        ),
                        _buildPlayerPicker()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
