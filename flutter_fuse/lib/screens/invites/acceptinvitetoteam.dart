import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../../widgets/util/byusername.dart';
import '../../widgets/util/savingoverlay.dart';
import 'dialog/deleteinvite.dart';

///
/// Shows the invite the team screen. and allow accepting.
///
class AcceptInviteToTeamScreen extends StatefulWidget {
  /// Constructor.
  AcceptInviteToTeamScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToTeamScreenState createState() {
    return _AcceptInviteToTeamScreenState();
  }
}

class _AcceptInviteToTeamScreenState extends State<AcceptInviteToTeamScreen> {
  Set<String> _checked;
  Map<String, String> _data;
  final Map<String, String> _original = <String, String>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _current = <String, String>{};
  final Map<String, Relationship> _relationship = <String, Relationship>{};
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  SingleInviteBloc _singleInviteBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _checked = <String>{};
    _data = <String, String>{};
    _singleInviteBloc = SingleInviteBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context),
        seasonBloc: BlocProvider.of<SeasonBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc.close();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _onChangedPlayer(String name, String uid) {
    setState(() {
      if (uid.compareTo(SingleInviteBloc.createNew) == 0) {
        _current[name] = SingleInviteBloc.createNew;
        _data[name] = _original[name];
        if (_relationship[name] == Relationship.Me) {
          _relationship[name] = Relationship.Friend;
        }
      } else {
        var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        var playerBloc = BlocProvider.of<PlayerBloc>(context);
        _current[name] = uid;
        _data[name] = authenticationBloc.currentUser.profile.displayName;
        _relationship[name] = playerBloc.state.players[uid]
            .users[authenticationBloc.currentUser.uid].relationship;
      }
    });
  }

  Widget _showPlayerDropdown(String name, PlayerState state) {
    var dropdowns = <DropdownMenuItem<String>>[];

    String found;
    var lowerName = name.toLowerCase().trim();

    for (var play in state.players.entries) {
      if (play.value.name.toLowerCase().trim().compareTo(lowerName) == 0) {
        found = play.key;
      }
      dropdowns.add(
        DropdownMenuItem<String>(child: Text(play.value.name), value: play.key),
      );
    }
    dropdowns.add(
      DropdownMenuItem<String>(
          child: Text(Messages.of(context).createNew),
          value: SingleInviteBloc.createNew),
    );
    if (found == null) {
      found = SingleInviteBloc.createNew;
    }
    if (!_current.containsKey(name)) {
      _current[name] = found;
      var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
      var playerBloc = BlocProvider.of<PlayerBloc>(context);
      var myUid = authenticationBloc.currentUser.uid;
      if (playerBloc.state.players.containsKey(found)) {
        _relationship[name] =
            playerBloc.state.players[found].users[myUid].relationship;
      } else {
        _relationship[name] = Relationship.Friend;
      }
    }
    return Container(
        child: DropdownButton<String>(
      items: dropdowns,
      onChanged: (val) {
        _onChangedPlayer(name, val);
      },
      value: _current[name],
    ));
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var currentCopy = Map<String, String>.from(_current);

      currentCopy.removeWhere((name, uid) => _checked.contains(name));
      _singleInviteBloc.add(SingleInviteEventAcceptInviteToTeam(
        relationship: _relationship,
        playerNameToUid: currentCopy,
      ));
    }
  }

  Widget _buildRelationshopDropDown(String name, bool disabled) {
    var dropdowns = <DropdownMenuItem<Relationship>>[];
    var theme = Theme.of(context);
    var messages = Messages.of(context);

    for (var rel in Relationship.values) {
      if (rel != Relationship.Me || disabled) {
        dropdowns.add(
          DropdownMenuItem<Relationship>(
              child: Text(messages.relationships(rel)), value: rel),
        );
      }
    }
    var textStyle = theme.textTheme.subtitle1;
    if (disabled) {
      textStyle = textStyle.copyWith(
        color: theme.disabledColor,
      );
    }
    print("${_relationship[name]} $_relationship");
    return DropdownButton<Relationship>(
      items: dropdowns,
      style: textStyle,
      onChanged: disabled
          ? null
          : (val) {
              _relationship[name] = val;
            },
      value: _relationship[name],
    );
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    var players = <Widget>[];
    var theme = Theme.of(context);
    var invite = _singleInviteBloc.state.invite as InviteToTeam;
    for (var name in invite.playerName) {
      if (!_controllers.containsKey(name)) {
        _controllers[name] = TextEditingController();
      }

      players.add(
        ListTile(
          leading: Checkbox(
            value: _checked.contains(name),
            onChanged: (value) {
              setState(
                () {
                  if (value) {
                    _checked.add(name);
                  } else {
                    _checked.remove(name);
                  }
                },
              );
            },
          ),
          title: BlocBuilder(
              cubit: BlocProvider.of<PlayerBloc>(context),
              builder: (context, state) {
                if (state is PlayerLoaded) {
                  return _showPlayerDropdown(name, state);
                } else {
                  return Text(Messages.of(context).unknown);
                }
              }),
          subtitle: _current[name].compareTo(SingleInviteBloc.createNew) == 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildRelationshopDropDown(name, false),
                    TextFormField(
                      controller: _controllers[name],
                      decoration: InputDecoration(
                        labelText: messages.newplayername,
                        hintText: messages.newplayernamehint,
                      ),
                      initialValue: name,
                      onSaved: (newName) {
                        _data[name] = newName;
                      },
                    ),
                    ByUserNameComponent(userId: invite.sentByUid),
                  ],
                )
              : FocusScope(
                  node: FocusScopeNode(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildRelationshopDropDown(name, true),
                      TextFormField(
                        controller: _controllers[name],
                        style: theme.textTheme.subtitle1.copyWith(
                          color: theme.disabledColor,
                        ),
                        decoration: InputDecoration(
                          labelText: messages.newplayername,
                          hintText: messages.newplayernamehint,
                        ),
                        initialValue: name,
                        onSaved: (newName) {
                          _data[name] = newName;
                        },
                      ),
                      ByUserNameComponent(userId: invite.sentByUid),
                    ],
                  ),
                ),
        ),
      );
    }

    players.add(
      Row(
        children: <Widget>[
          RaisedButton(
            onPressed: _savePressed,
            child: Text(messages.addinvite),
            color: theme.accentColor,
            textColor: Colors.white,
          ),
          FlatButton(
            onPressed: () => showDeleteInvite(context, _singleInviteBloc),
            child: Text(messages.deleteinvite),
          ),
        ],
      ),
    );

    return BlocListener(
      cubit: _singleInviteBloc,
      listener: (context, state) {
        if (state is SingleInviteDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocProvider<SingleInviteBloc>.value(
        value: _singleInviteBloc,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(Messages.of(context).title),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _savePressed();
                },
                child: Text(
                  Messages.of(context).savebuttontext,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Scrollbar(
            child: SingleChildScrollView(
              child: BlocListener(
                cubit: _singleInviteBloc,
                listener: (context, state) {
                  if (state is SingleInviteDeleted) {
                    // go back!
                    Navigator.pop(context);
                  }
                },
                child: BlocBuilder(
                  cubit: _singleInviteBloc,
                  builder: (context, state) {
                    if (state is SingleInviteDeleted) {
                      // Go back!
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (state is SingleInviteSaveFailed) {
                        _showInSnackBar(Messages.of(context).formerror);
                      }
                      var invite = state.invite as InviteToTeam;
                      return SavingOverlay(
                        saving: !(state is SingleInviteLoaded),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                                  ListTile(
                                    leading: const Icon(MdiIcons.tshirtCrew),
                                    title: Text(invite.teamName),
                                    subtitle: Text(invite.seasonName),
                                  )
                                ] +
                                players,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
