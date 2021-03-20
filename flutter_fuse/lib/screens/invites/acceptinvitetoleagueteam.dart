import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/form/seasonformfield.dart';
import '../../widgets/form/teampicker.dart';
import '../../widgets/leagueortournament/leagueimage.dart';
import '../../widgets/util/byusername.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';
import 'dialog/deleteinvite.dart';

///
/// Screen to display an accept invite to the league team.
///
class AcceptInviteToLeagueTeamScreen extends StatefulWidget {
  /// Constructor
  AcceptInviteToLeagueTeamScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToLeagueTeamScreenState createState() {
    return _AcceptInviteToLeagueTeamScreenState();
  }
}

class _AcceptInviteToLeagueTeamScreenState
    extends State<AcceptInviteToLeagueTeamScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentTeamUid;
  String _seasonSelected = SeasonFormField.none;
  final GlobalKey<FormState> _seasonForm = GlobalKey<FormState>();
  final FocusNode _focusNodeSeason = FocusNode();
  final Validations _validations = Validations();
  String _seasonName;
  bool _saving = false;
  SingleInviteBloc _singleInviteBloc;

  @override
  void initState() {
    super.initState();
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
    _singleInviteBloc?.close();
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
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

    var res = await showDialog<bool>(
        context: context,
        builder: (context) {
          var inviteToLeagueTeam =
              _singleInviteBloc.state.invite as InviteToLeagueTeam;

          return AlertDialog(
            title: Text(Messages.of(context).league),
            content: RichText(
              text: TextSpan(
                text: Messages.of(context).confirmCreateTeamForLeague(
                    inviteToLeagueTeam.leagueTeamName,
                    _seasonName,
                    inviteToLeagueTeam.leagueName),
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
      child: TextFormField(
        decoration: InputDecoration(
          icon: const Icon(Icons.calendar_today),
          hintText: Messages.of(context).season,
          labelText: Messages.of(context).seasonhint,
        ),
        focusNode: _focusNodeSeason,
        initialValue: invite.leagueSeasonName,
        keyboardType: TextInputType.text,
        obscureText: false,
        validator: (value) {
          return _validations.validateSeason(context, value);
        },
        onSaved: (value) {
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
        onFieldSubmitted: (str) => setState(() => _seasonSelected = str),
        onSaved: (str) => _seasonSelected = str,
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
    var messages = Messages.of(context);

    var theme = Theme.of(context);

    return BlocProvider<SingleInviteBloc>.value(
      value: _singleInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Messages.of(context).league),
        ),
        body: SavingOverlay(
          saving: _saving,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: BlocListener(
                  bloc: _singleInviteBloc,
                  listener: (context, state) {
                    if (state is SingleInviteDeleted) {
                      Navigator.pop(context);
                    }
                  },
                  child: BlocBuilder(
                    bloc: _singleInviteBloc,
                    builder: (context, state) {
                      if (state is SingleInviteDeleted) {
                        // Deleted.
                        return Center(child: CircularProgressIndicator());
                      } else {
                        var inviteToLeagueTeam =
                            state.invite as InviteToLeagueTeam;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              leading: LeagueImage(
                                leagueOrTournamentUid:
                                    inviteToLeagueTeam.leagueUid,
                                width: 50.0,
                                height: 50.0,
                              ),
                              title: Text(inviteToLeagueTeam.leagueTeamName),
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
                              onChanged: (str) =>
                                  setState(() => _currentTeamUid = str),
                            ),
                            SingleTeamProvider(
                              teamUid: _currentTeamUid,
                              builder: (context, bloc) =>
                                  _buildSeasonSection(inviteToLeagueTeam, bloc),
                            ),
                            ButtonBar(
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: _savePressed,
                                  color: theme.accentColor,
                                  textColor: Colors.white,
                                  child: Text(messages.addTeamButton),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context,
                                      '/League/Main/${inviteToLeagueTeam.leagueUid}'),
                                  child: Text(messages.openbutton),
                                ),
                                TextButton(
                                  onPressed: () => showDeleteInvite(
                                      context, _singleInviteBloc),
                                  child: Icon(Icons.delete),
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
        floatingActionButton: FloatingActionButton(
          onPressed: _savePressed,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
