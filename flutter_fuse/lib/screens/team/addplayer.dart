import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
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
  InviteTeamData data = InviteTeamData((b) => b
    ..email = ''
    ..playerName = ''
    ..role = RoleInTeam.Player);
  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodeName = FocusNode();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final Validations _validations = Validations();
  final _EmailName _emailName = _EmailName();
  bool autovalidate = false;
  String _curSeasonUid;
  String _jerseyNumber;

  AddInviteBloc addInviteBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeJersey = FocusNode();

  @override
  void initState() {
    super.initState();
    _curSeasonUid = widget._seasonUid;
    addInviteBloc = AddInviteBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  Future<void> _handleSubmit(Team team, Season season) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_emailName.data.email.isEmpty) {
        // Ask if they really want to add a player with no email address.
        var res = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(Messages.of(context).addPlayer),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(Messages.of(context).checkPlayerNoEmail),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child:
                      Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            );
          },
        );
        if (!res) {
          return;
        }
      }
      // Send the invite, cloud functions will handle the email
      // part of this.
      addInviteBloc.add(InvitePlayersToTeam(
        seasonUid: widget._seasonUid,
        seasonName: season.name,
        invite: _emailName.data,
        teamUid: team.uid,
        teamName: team.name,
        jerseyNumber: _jerseyNumber,
      ));
    } else {
      autovalidate = true;
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildForm(
      SingleTeamBloc singleTeamBloc, SingleSeasonBloc singleSeasonBloc) {
    var rows = <Widget>[];
    var messages = Messages.of(context);

    rows.add(
      DropdownButtonHideUnderline(
        child: SeasonFormField(
          initialValue: _curSeasonUid,
          teamBloc: singleTeamBloc,
          onSaved: (value) {
            _curSeasonUid = value;
          },
        ),
      ),
    );

    rows.add(
      EnsureVisibleWhenFocused(
        focusNode: _emailName.focusNodeName,
        child: TextFormField(
          key: _emailName.nameKey,
          initialValue: '',
          decoration: InputDecoration(
              icon: const Icon(Icons.person),
              labelText: messages.name,
              hintText: messages.displaynamehint),
          validator: (value) {
            return _validations.validateDisplayName(context, value);
          },
          focusNode: _emailName.focusNodeName,
          keyboardType: TextInputType.text,
          onSaved: (value) {
            _emailName.data =
                _emailName.data.rebuild((b) => b..playerName = value);
          },
        ),
      ),
    );

    rows.add(
      EnsureVisibleWhenFocused(
        focusNode: _emailName.focusNodeEmail,
        child: TextFormField(
          initialValue: '',
          decoration: InputDecoration(
              icon: const Icon(Icons.email),
              labelText: messages.email,
              hintText: messages.playeremailHint),
          validator: (value) {
            // Allow no email, or an email for an invite.
            if (value.isEmpty) {
              return null;
            }
            return _validations.validateEmail(context, value);
          },
          focusNode: _emailName.focusNodeEmail,
          keyboardType: TextInputType.emailAddress,
          onSaved: (value) {
            _emailName.data = _emailName.data.rebuild((b) => b..email = value);
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
        validator: (val) {
          return _validations.validateRoleInTeam(context, val);
        },
        onSaved: (val) {
          _emailName.data = _emailName.data.rebuild((b) => b
            ..role = RoleInTeam.values.firstWhere((e) => e.toString() == val));
        },
      ),
    );

    rows.add(
      EnsureVisibleWhenFocused(
        focusNode: _focusNodeJersey,
        child: TextFormField(
          initialValue: '',
          decoration: InputDecoration(
            icon: const Icon(MdiIcons.tshirtCrew),
            labelText: messages.roleselect,
          ),
          onSaved: (val) {
            _jerseyNumber = val;
          },
        ),
      ),
    );

    return SingleChildScrollView(
      child: Form(
        autovalidateMode:
            autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
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
                    return TextButton(
                      onPressed: null,
                      child: Text(Messages.of(context).loading),
                    );
                  }
                  return ButtonBar(
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleSubmit(
                            singleTeamBloc.state.team,
                            singleSeasonBloc.state.season),
                        child: Text(Messages.of(context).addButton),
                      ),
                    ],
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
      create: (context) => addInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Messages.of(context).addPlayer),
        ),
        body: BlocListener(
          cubit: addInviteBloc,
          listener: (context, state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              _showInSnackBar(Messages.of(context).formerror);
            }
          },
          child: BlocBuilder(
            cubit: addInviteBloc,
            builder: (context, state) => SavingOverlay(
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
