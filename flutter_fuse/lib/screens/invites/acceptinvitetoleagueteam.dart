import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

class AcceptInviteToLeagueTeamScreen extends StatefulWidget {
  AcceptInviteToLeagueTeamScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToLeagueTeamScreenState createState() {
    return new _AcceptInviteToLeagueTeamScreenState();
  }
}

class _AcceptInviteToLeagueTeamScreenState
    extends State<AcceptInviteToLeagueTeamScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  InviteToLeagueTeam _invite;
  String _currentTeamUid;
  String _seasonSelected = SeasonFormField.none;
  GlobalKey<FormState> _seasonForm = new GlobalKey<FormState>();
  FocusNode _focusNodeSeason = new FocusNode();
  Validations _validations = new Validations();
  String _seasonName;
  bool _saving = false;
  SingleInviteBloc _singleInviteBloc;

  @override
  void initState() {
    super.initState();
    // Default to empty.
    if (UserDatabaseData.instance.invites.containsKey(widget._inviteUid)) {
      _invite = UserDatabaseData.instance.invites[widget._inviteUid]
          as InviteToLeagueTeam;
    } else {
      // Get out of here.
      _invite = new InviteToLeagueTeam(
          (InviteToLeagueTeamBuilder b) => b..leagueTeamUid = '');

      Navigator.pop(context);
    }

    _singleInviteBloc = SingleInviteBloc(
        inviteBloc: BlocProvider.of<InviteBloc>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc?.dispose();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    // Show an are you sure dialog in this case.
    if (!_seasonForm.currentState.validate()) {
      // Show an error.
      setState(() {});
      _showInSnackBar(Messages.of(context).formerror);
      return;
    }
    _seasonForm.currentState.save();

    bool res = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Messages.of(context).league),
            content: RichText(
              text: TextSpan(
                text: Messages.of(context).confirmcreateteamforleague(
                    _invite.leagueTeamName, _seasonName, _invite.leagueName),
                style: Theme.of(context).textTheme.body1,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () => Navigator.pop(context, true),
              ),
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => Navigator.pop(context, false),
              )
            ],
          );
        });
    if (res) {
      setState(() => _saving = true);
      _singleInviteBloc.dispatch(SingleInviteEventAcceptInviteToLeagueTeam(
        teamUid: _currentTeamUid,
        seasonUid: _seasonSelected,
      ));
      await for (var state in _singleInviteBloc.state) {
        if (state is SingleInviteSaveFailed) {
          _showInSnackBar(Messages.of(context).formerror);
        } else if (state is SingleInviteDeleted) {
          Navigator.pop(context);
        } else if (state is SingleInviteLoaded) {
          break;
        }
      }
      /*
      TeamBloc teamBloc = BlocProvider.of<TeamBloc>(context);
      try {
        SeasonBuilder season;

        if (_currentTeamUid == TeamPicker.createNew) {
          TeamBuilder team = new TeamBuilder();
            team.name =_invite.leagueTeamName;
            String myUid= teamBloc.coordinationBloc.authenticationBloc.currentUser.uid;

          team.admins.add(myUid);
          season = new SeasonBuilder();
          season.
              name =_seasonName;
              season.record =WinRecordBuilder();
              season.players.add(SeasonPlayer((b) => b..playerUid = myUid
              ..role = RoleInTeam.NonPlayer);
          LeagueOrTournamentTeam leagueTeam = await UserDatabaseData
              .instance.updateModel
              .getLeagueTeamData(_invite.leagueTeamUid);
          SingleTeamBloc singleTeamBloc = new SingleTeamBloc(teamBloc: teamBloc, teamUid: SingleTeamBloc.createNew);
          singleTeamBloc.dispatch(SingleTeamAdd(newSeason: season, newTeam: team));
          Team savedTeam;
          await for (SingleTeamState state in singleTeamBloc.state) {
            if (state is SingleTeamSaveFailed) {
              // Fail!
              _showInSnackBar(Messages.of(context).formerror);
              return;
            }
            if (state is SingleTeamLoaded) {
              // Yay!
              savedTeam = state.team;
            }
          }

          if (leagueTeam.seasonUid != null) {
            // Someone beat them to it!
            // TODO: Say someone beat them to it.
          } else {
            leagueTeam.seasonUid = savedTeam.currentSeason;
            await leagueTeam.firebaseUpdate();
          }
        } else if (_seasonSelected == SeasonFormField.createNew) {
          season = new SeasonBuilder(
            name: _seasonName,
            teamUid: _currentTeamUid,
          );
          await season.updateFirestore();
        } else {
          season = team
              .instance.teams[_currentTeamUid].seasons[_seasonSelected];
        }
        await _invite.acceptInvite(season);
        await _invite.firestoreDelete();
        Navigator.pushNamed(context, "/Team/" + _currentTeamUid);
      } finally {
        setState(() => _saving = false);
      }
    */
    }

    // _invite.acceptInvite();
    // await _invite.firestoreDelete();
    // Navigator.pop(context);
  }

  Widget _buildSeasonTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: _focusNodeSeason,
      child: new TextFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: Messages.of(context).season,
          labelText: Messages.of(context).seasonhint,
        ),
        focusNode: _focusNodeSeason,
        initialValue: _invite.leagueSeasonName,
        keyboardType: TextInputType.text,
        obscureText: false,
        validator: (String value) {
          return _validations.validateSeason(context, value);
        },
        onSaved: (String value) {
          _seasonName = value;
        },
      ),
    );
  }

  Widget _buildSeasonSection() {
    if (_currentTeamUid == null) {
      return SizedBox(
        height: 0.0,
      );
    }
    Widget formChildren;

    if (_currentTeamUid == TeamPicker.createNew) {
      formChildren = Column(
        children: <Widget>[_buildSeasonTextField()],
      );
    } else {
      formChildren = SeasonFormField(
        initialValue: _seasonSelected,
        includeNone: true,
        includeNew: true,
        teamUid: _currentTeamUid,
        enabled: _currentTeamUid != null,
        onFieldSubmitted: (String str) => setState(() => _seasonSelected = str),
        onSaved: (String str) => _seasonSelected = str,
      );
      if (_seasonSelected == SeasonFormField.createNew) {
        formChildren = Column(
          children: <Widget>[formChildren, _buildSeasonTextField()],
        );
      }
    }

    return Form(key: _seasonForm, child: formChildren);
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    ThemeData theme = Theme.of(context);

    return BlocProvider<SingleInviteBloc>(
      bloc: _singleInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(Messages.of(context).league),
        ),
        body: SavingOverlay(
          saving: _saving,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Scrollbar(
              child: new SingleChildScrollView(
                child: BlocBuilder(
                    bloc: _singleInviteBloc,
                    builder: (BuildContext context, SingleInviteState state) {
                      if (state is SingleInviteDeleted) {
                        // Deleted.
                        return Center(child: CircularProgressIndicator());
                      } else if (state is SingleInviteUninitialized) {
                        // Loading.
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new ListTile(
                              leading: LeagueImage(
                                leagueOrTournamentUid: _invite.leagueUid,
                                width: 50.0,
                                height: 50.0,
                              ),
                              title: new Text(_invite.leagueTeamName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(_invite.leagueName),
                                  ByUserNameComponent(
                                      userId: _invite.sentByUid),
                                ],
                              ),
                            ),
                            TeamPicker(
                              includeCreateNew: true,
                              teamUid: _currentTeamUid,
                              onChanged: (String str) =>
                                  setState(() => _currentTeamUid = str),
                            ),
                            _buildSeasonSection(),
                            ButtonBar(
                              children: <Widget>[
                                new RaisedButton(
                                  onPressed: _savePressed,
                                  child: new Text(messages.addteam),
                                  color: theme.accentColor,
                                  textColor: Colors.white,
                                ),
                                new FlatButton(
                                  onPressed: () => Navigator.pushNamed(context,
                                      "/League/Main/" + _invite.leagueUid),
                                  child: Text(messages.openbutton),
                                ),
                                new FlatButton(
                                  onPressed: () => showDeleteInvite(
                                      context, _singleInviteBloc),
                                  child: new Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    }),
              ),
            ),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => _savePressed(),
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
