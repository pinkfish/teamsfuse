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

import '../../widgets/blocs/singleteamprovider.dart';
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
    _singleInviteBloc = SingleInviteBloc(
        inviteBloc: BlocProvider.of<InviteBloc>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context),
        seasonBloc: BlocProvider.of<SeasonBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc?.close();
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
          InviteToLeagueTeam inviteToLeagueTeam =
              _singleInviteBloc.state.invite as InviteToLeagueTeam;

          return AlertDialog(
            title: Text(Messages.of(context).league),
            content: RichText(
              text: TextSpan(
                text: Messages.of(context).confirmcreateteamforleague(
                    inviteToLeagueTeam.leagueTeamName,
                    _seasonName,
                    inviteToLeagueTeam.leagueName),
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
      _singleInviteBloc.add(SingleInviteEventAcceptInviteToLeagueTeam(
          teamUid: _currentTeamUid, seasonUid: _seasonSelected));
    }
  }

  Widget _buildSeasonTextField(InviteToLeagueTeam invite) {
    return EnsureVisibleWhenFocused(
      focusNode: _focusNodeSeason,
      child: new TextFormField(
        decoration: new InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: Messages.of(context).season,
          labelText: Messages.of(context).seasonhint,
        ),
        focusNode: _focusNodeSeason,
        initialValue: invite.leagueSeasonName,
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

  Widget _buildSeasonSection(InviteToLeagueTeam invite, SingleTeamBloc bloc) {
    if (_currentTeamUid == null) {
      return SizedBox(
        height: 0.0,
      );
    }
    Widget formChildren;

    if (_currentTeamUid == TeamPicker.createNew) {
      formChildren = Column(
        children: <Widget>[_buildSeasonTextField(invite)],
      );
    } else {
      formChildren = SeasonFormField(
        initialValue: _seasonSelected,
        includeNone: true,
        includeNew: true, teamBloc: bloc,
        // teamUid: _currentTeamUid,
        enabled: _currentTeamUid != null,
        onFieldSubmitted: (String str) => setState(() => _seasonSelected = str),
        onSaved: (String str) => _seasonSelected = str,
      );
      if (_seasonSelected == SeasonFormField.createNew) {
        formChildren = Column(
          children: <Widget>[formChildren, _buildSeasonTextField(invite)],
        );
      }
    }

    return Form(key: _seasonForm, child: formChildren);
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    ThemeData theme = Theme.of(context);

    return BlocProvider<SingleInviteBloc>.value(
      value: _singleInviteBloc,
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
                child: BlocListener(
                  cubit: _singleInviteBloc,
                  listener: (BuildContext context, SingleInviteState state) {
                    if (state is SingleInviteDeleted) {
                      Navigator.pop(context);
                    }
                  },
                  child: BlocBuilder(
                    cubit: _singleInviteBloc,
                    builder: (BuildContext context, SingleInviteState state) {
                      if (state is SingleInviteDeleted) {
                        // Deleted.
                        return Center(child: CircularProgressIndicator());
                      } else {
                        InviteToLeagueTeam inviteToLeagueTeam =
                            state.invite as InviteToLeagueTeam;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new ListTile(
                              leading: LeagueImage(
                                leagueOrTournamentUid:
                                    inviteToLeagueTeam.leagueUid,
                                width: 50.0,
                                height: 50.0,
                              ),
                              title:
                                  new Text(inviteToLeagueTeam.leagueTeamName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(inviteToLeagueTeam.leagueName),
                                  ByUserNameComponent(
                                      userId: inviteToLeagueTeam.sentByUid),
                                ],
                              ),
                            ),
                            TeamPicker(
                              includeCreateNew: true,
                              teamUid: _currentTeamUid,
                              onChanged: (String str) =>
                                  setState(() => _currentTeamUid = str),
                            ),
                            SingleTeamProvider(
                              teamUid: _currentTeamUid,
                              builder: (BuildContext context,
                                      SingleTeamBloc bloc) =>
                                  _buildSeasonSection(inviteToLeagueTeam, bloc),
                            ),
                            ButtonBar(
                              children: <Widget>[
                                new RaisedButton(
                                  onPressed: _savePressed,
                                  child: new Text(messages.addteam),
                                  color: theme.accentColor,
                                  textColor: Colors.white,
                                ),
                                new FlatButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context,
                                      "/League/Main/" +
                                          inviteToLeagueTeam.leagueUid),
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
                    },
                  ),
                ),
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
