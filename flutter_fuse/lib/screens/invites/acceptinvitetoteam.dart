import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/util/byusername.dart';
import '../../widgets/util/communityicons.dart';
import '../../widgets/util/savingoverlay.dart';
import 'dialog/deleteinvite.dart';

///
/// Shows the invite the team screen.
///
class AcceptInviteToTeamScreen extends StatefulWidget {
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
  Map<String, String> _original = <String, String>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> _current = <String, String>{};
  Map<String, Relationship> _relationship = <String, Relationship>{};
  Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  SingleInviteBloc _singleInviteBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _checked = Set<String>();
    _data = <String, String>{};
    _singleInviteBloc = SingleInviteBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        analytisSubsystem: RepositoryProvider.of<AnalyticsSubsystem>(context),
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
        AuthenticationBloc authenticationBloc =
            BlocProvider.of<AuthenticationBloc>(context);
        PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
        _current[name] = uid;
        _data[name] = authenticationBloc.currentUser.profile.displayName;
        _relationship[name] = playerBloc.state.players[uid]
            .users[authenticationBloc.currentUser.uid].relationship;
      }
    });
  }

  Widget _showPlayerDropdown(String name, PlayerState state) {
    List<DropdownMenuItem<String>> dropdowns = <DropdownMenuItem<String>>[];

    String found;
    String lowerName = name.toLowerCase().trim();

    state.players.forEach((String uid, Player play) {
      if (play.name.toLowerCase().trim().compareTo(lowerName) == 0) {
        found = uid;
      }
      dropdowns.add(
        DropdownMenuItem<String>(child: Text(play.name), value: play.uid),
      );
    });
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
      AuthenticationBloc authenticationBloc =
          BlocProvider.of<AuthenticationBloc>(context);
      PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
      String myUid = authenticationBloc.currentUser.uid;
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
      onChanged: (String val) {
        _onChangedPlayer(name, val);
      },
      value: _current[name],
    ));
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String, String> currentCopy = Map<String, String>.from(_current);

      currentCopy
          .removeWhere((String name, String uid) => _checked.contains(name));
      _singleInviteBloc.add(SingleInviteEventAcceptInviteToTeam(
        relationship: _relationship,
        playerNameToUid: currentCopy,
      ));
    }
  }

  Widget _buildRelationshopDropDown(String name, bool disabled) {
    List<DropdownMenuItem<Relationship>> dropdowns =
        <DropdownMenuItem<Relationship>>[];
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    Relationship.values.forEach((Relationship rel) {
      if (rel != Relationship.Me || disabled) {
        dropdowns.add(
          DropdownMenuItem<Relationship>(
              child: Text(messages.relationships(rel)), value: rel),
        );
      }
    });
    TextStyle textStyle = theme.textTheme.subhead;
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
          : (Relationship val) {
              _relationship[name] = val;
            },
      value: _relationship[name],
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    List<Widget> players = <Widget>[];
    ThemeData theme = Theme.of(context);
    InviteToTeam invite = _singleInviteBloc.state.invite as InviteToTeam;
    invite.playerName.forEach(
      (String name) {
        if (!_controllers.containsKey(name)) {
          _controllers[name] = TextEditingController();
        }

        players.add(
          ListTile(
            leading: Checkbox(
              value: _checked.contains(name),
              onChanged: (bool value) {
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
                builder: (BuildContext context, PlayerState state) {
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
                        onSaved: (String newName) {
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
                          style: theme.textTheme.subhead.copyWith(
                            color: theme.disabledColor,
                          ),
                          decoration: InputDecoration(
                            labelText: messages.newplayername,
                            hintText: messages.newplayernamehint,
                          ),
                          initialValue: name,
                          onSaved: (String newName) {
                            _data[name] = newName;
                          },
                        ),
                        ByUserNameComponent(userId: invite.sentByUid),
                      ],
                    ),
                  ),
          ),
        );
      },
    );

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
      listener: (BuildContext context, SingleInviteState state) {
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
                      .subhead
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Scrollbar(
            child: SingleChildScrollView(
              child: BlocListener(
                cubit: _singleInviteBloc,
                listener: (BuildContext context, SingleInviteState state) {
                  if (state is SingleInviteDeleted) {
                    // go back!
                    Navigator.pop(context);
                  }
                },
                child: BlocBuilder(
                  cubit: _singleInviteBloc,
                  builder: (BuildContext context, SingleInviteState state) {
                    if (state is SingleInviteDeleted) {
                      // Go back!
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (state is SingleInviteSaveFailed) {
                        _showInSnackBar(Messages.of(context).formerror);
                      }
                      InviteToTeam invite = state.invite as InviteToTeam;
                      return SavingOverlay(
                        saving: !(state is SingleInviteLoaded),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                                  ListTile(
                                    leading:
                                        const Icon(CommunityIcons.tshirtCrew),
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
