import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleteamprovider.dart';

class AddMessageScreen extends StatefulWidget {
  AddMessageScreen({this.teamUid, this.seasonUid, this.playerUid});

  final String teamUid;
  final String seasonUid;
  final String playerUid;

  @override
  AddMessageScreenState createState() {
    return new AddMessageScreenState();
  }
}

class AddMessageScreenState extends State<AddMessageScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _seasonUid;
  String _sendAs;
  List<String> _possiblePlayers = <String>[];
  bool _allPlayers = true;
  bool _includeMyself = false;
  FocusNode _focusNodeSubject = new FocusNode();
  FocusNode _focusNodeBody = new FocusNode();
  TeamBloc _teamBloc;
  SeasonBloc _seasonBloc;
  String _messageBody;
  AddMessageBloc addMessageBloc;
  String _teamUid;
  Set<String> _recipients = Set();
  String _subject;

  @override
  void initState() {
    super.initState();
    _teamBloc = BlocProvider.of<TeamBloc>(context);
    _seasonBloc = BlocProvider.of<SeasonBloc>(context);

    _teamUid = widget.teamUid;
    _seasonUid = widget.seasonUid;
    addMessageBloc = new AddMessageBloc(
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
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _sendMessage() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_allPlayers) {
        // Add in everyone!
        _seasonBloc.state.seasons[_seasonUid].players
            .forEach((SeasonPlayer play) {
          if (_includeMyself || play.playerUid != _sendAs) {
            _recipients.add(play.playerUid);
          }
        });
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
    }
  }

  List<Widget> _buildPlayerPicker(SingleTeamBloc singleTeamBloc) {
    List<Widget> ret = <Widget>[];
    PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);

    if (_teamUid != null) {
      // Build the rest of the form.
      ret.add(
        new SeasonFormField(
            teamBloc: singleTeamBloc,
            initialValue: _seasonUid,
            onSaved: (String seasonUid) => _seasonUid = seasonUid),
      );
      if (_seasonUid != null &&
          _teamBloc.state.getTeam(_teamUid) != null &&
          _seasonBloc.state.seasons.containsKey(_seasonUid)) {
        // Show who we are sending as, drop down if there is more than one
        // option.
        if (_possiblePlayers.length > 1) {
          ret.add(
            new ListTile(
              leading: const Icon(Icons.person_outline),
              title: new DropdownButton<String>(
                  value: _sendAs,
                  items: _possiblePlayers.map((String str) {
                    PlayerBloc playerBloc =
                        BlocProvider.of<PlayerBloc>(context);
                    return new DropdownMenuItem<String>(
                        child: new Text(playerBloc.state.players[str].name),
                        value: str);
                  }).toList(),
                  onChanged: (String str) {
                    _sendAs = str;
                  }),
            ),
          );
        } else {
          ret.add(
            new ListTile(
              leading: const Icon(Icons.person_outline),
              title: new Text(playerBloc.state.players[_sendAs].name),
            ),
          );
        }
        // Show the player selection details.
        ret.add(
          new CheckboxListTile(
            secondary: const Icon(Icons.people),
            controlAffinity: ListTileControlAffinity.trailing,
            value: _allPlayers,
            onChanged: (bool newVal) => setState(() => _allPlayers = newVal),
            title: new Text(Messages.of(context).everyone),
          ),
        );
        if (_allPlayers) {
          ret.add(
            new CheckboxListTile(
              secondary: const Icon(Icons.person),
              controlAffinity: ListTileControlAffinity.trailing,
              value: _includeMyself,
              onChanged: (bool newVal) =>
                  setState(() => _includeMyself = newVal),
              title: new Text(Messages.of(context).includemyself),
            ),
          );
        } else {
          // Show the list of players with checkboxes.
          Season season = _seasonBloc.state.seasons[_seasonUid];

          season.players.forEach((SeasonPlayer player) {
            ret.add(
              new CheckboxListTile(
                title: new PlayerName(playerUid: player.playerUid),
                subtitle:
                    new Text(Messages.of(context).roleingame(player.role)),
                value: _recipients.contains(player.playerUid),
                onChanged: (bool toAdd) {
                  if (toAdd) {
                    _recipients.add(player.playerUid);
                  } else {
                    _recipients.remove(player.playerUid);
                  }
                },
              ),
            );
          });
        }
        // Add in the message box itself :)
        ret.add(
          new EnsureVisibleWhenFocused(
            child: new TextFormField(
              decoration: new InputDecoration(
                icon: const Icon(Icons.subject),
                labelText: Messages.of(context).subject,
              ),
              focusNode: _focusNodeSubject,
              initialValue: _subject,
              onSaved: (String val) => _subject = val,
            ),
            focusNode: _focusNodeSubject,
          ),
        );
        ret.add(
          new EnsureVisibleWhenFocused(
            focusNode: _focusNodeBody,
            child: new TextFormField(
              decoration: new InputDecoration(
                icon: const Icon(Icons.message),
                labelText: Messages.of(context).message,
              ),
              focusNode: _focusNodeBody,
              initialValue: _messageBody,
              onSaved: (String val) => _messageBody = val,
            ),
          ),
        );
      }
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (BuildContext conext, SingleTeamBloc teamBloc) => Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(messages.title),
          actions: <Widget>[
            new FlatButton(
              onPressed: _sendMessage,
              child: new Text(
                Messages.of(context).sendmessagebuttontext,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        body: BlocListener(
          cubit: addMessageBloc,
          listener: (BuildContext context, AddItemState state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed ||
                state is AddItemInvalidArguments) {
              _showInSnackBar(Messages.of(context).formerror);
            }
          },
          child: BlocBuilder(
            cubit: addMessageBloc,
            builder: (BuildContext context, AddItemState state) =>
                SavingOverlay(
              saving: state is AddItemSaving,
              child: Scrollbar(
                child: new SingleChildScrollView(
                  child: new DropdownButtonHideUnderline(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                              new ListTile(
                                leading: const Icon(CommunityIcons.tshirtCrew),
                                title: new TeamPicker(
                                  onChanged: _changeTeam,
                                ),
                              ),
                            ] +
                            _buildPlayerPicker(teamBloc),
                      ),
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
