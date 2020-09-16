import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleseasonprovider.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/form/roleinteamformfield.dart';
import '../../widgets/form/seasonformfield.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add a player to the team and season.
///
class AddPlayerScreen extends StatefulWidget {
  /// Constrctor.
  AddPlayerScreen(this._teamUid, this._seasonUid);

  final String _teamUid;
  final String _seasonUid;

  @override
  _AddPlayerScreenState createState() {
    return _AddPlayerScreenState();
  }
}

class _EmailName {
  final GlobalKey<FormFieldState<String>> nameKey =
      GlobalKey<FormFieldState<String>>();
  InviteTeamData data;
  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodeName = FocusNode();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final Validations _validations = Validations();
  final List<_EmailName> _emailNames = <_EmailName>[];
  bool autovalidate = false;
  String _curSeasonUid;

  AddInviteBloc addInviteBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _curSeasonUid = widget._seasonUid;
    addInviteBloc = AddInviteBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  void _handleSubmit(Team team, Season season) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Send the invite, cloud functions will handle the email
      // part of this.
      addInviteBloc.add(InvitePlayersToTeam(
        seasonUid: widget._seasonUid,
        seasonName: season.name,
        invites: _emailNames.map((b) => b.data),
        teamUid: team.uid,
        teamName: team.name,
      ));
    } else {
      autovalidate = true;
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildForm(
      SingleTeamBloc singleTeamBloc, SingleSeasonBloc singleSeasonBloc) {
    List<Widget> rows = <Widget>[];
    Messages messages = Messages.of(context);

    rows.add(
      DropdownButtonHideUnderline(
        child: SeasonFormField(
          initialValue: _curSeasonUid,
          teamBloc: singleTeamBloc,
          onSaved: (String value) {
            _curSeasonUid = value;
          },
        ),
      ),
    );

    if (_emailNames.length == 0) {
      // Add in the start elements.
      _emailNames.add(_EmailName());
    }
    for (_EmailName en in _emailNames) {
      rows.add(
        EnsureVisibleWhenFocused(
          focusNode: en.focusNodeName,
          child: TextFormField(
            key: en.nameKey,
            initialValue: '',
            decoration: InputDecoration(
                icon: const Icon(Icons.person),
                labelText: messages.displayname,
                hintText: messages.displaynamehint),
            validator: (String value) {
              return _validations.validateDisplayName(context, value);
            },
            focusNode: en.focusNodeName,
            keyboardType: TextInputType.text,
            onSaved: (String value) {
              en.data = en.data.rebuild((b) => b..playerName = value);
            },
          ),
        ),
      );

      rows.add(
        EnsureVisibleWhenFocused(
          focusNode: en.focusNodeEmail,
          child: TextFormField(
            initialValue: '',
            decoration: InputDecoration(
                icon: const Icon(Icons.email),
                labelText: messages.email,
                hintText: messages.playeremailHint),
            validator: (String value) {
              return _validations.validateEmail(context, value);
            },
            focusNode: en.focusNodeEmail,
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (String value) {
              if (value.isNotEmpty &&
                  en.nameKey.currentState.value.isNotEmpty &&
                  en == _emailNames.last) {
                setState(() {
                  _emailNames.add(_EmailName());
                });
              }
            },
            onSaved: (String value) {
              en.data = en.data.rebuild((b) => b..email = value);
            },
          ),
        ),
      );

      rows.add(
        RoleInTeamFormField(
          initialValue: 'none',
          decoration: InputDecoration(
            icon: const Icon(Icons.message),
            labelText: messages.roleselect,
          ),
          validator: (String val) {
            return _validations.validateRoleInTeam(context, val);
          },
          onSaved: (String val) {
            en.data = en.data.rebuild((b) => b
              ..role = RoleInTeam.values
                  .firstWhere((RoleInTeam e) => e.toString() == val));
          },
        ),
      );
    }

    return SingleChildScrollView(
      child: Form(
        autovalidate: autovalidate,
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Scrollbar(
              child: SingleChildScrollView(
                child: Column(children: rows),
              ),
            ),
            BlocBuilder(
              cubit: singleTeamBloc,
              builder: (context, teamState) => BlocBuilder(
                cubit: singleSeasonBloc,
                builder: (context, seasonBloc) {
                  if (teamState is SingleTeamUninitialized ||
                      seasonBloc is SingleSeasonUninitialized) {
                    return FlatButton(
                      child: Text(Messages.of(context).loading),
                    );
                  }
                  return FlatButton(
                    onPressed: () => _handleSubmit(singleTeamBloc.state.team,
                        singleSeasonBloc.state.season),
                    child: Text(Messages.of(context).addplayer),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => addInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Messages.of(context).addplayer),
        ),
        body: BlocListener(
          cubit: addInviteBloc,
          listener: (BuildContext context, AddItemState state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              _showInSnackBar(Messages.of(context).formerror);
            }
          },
          child: BlocBuilder(
            cubit: addInviteBloc,
            builder: (BuildContext context, AddItemState state) =>
                SavingOverlay(
              saving: state is AddItemSaving,
              child: SingleTeamProvider(
                teamUid: widget._teamUid,
                builder: (contextl, singleTeamBloc) => SingleSeasonProvider(
                  seasonUid: widget._seasonUid,
                  builder: (context, singleSeasonBloc) =>
                      _buildForm(singleTeamBloc, singleSeasonBloc),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
