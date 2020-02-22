import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/roleinteamformfield.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleteamprovider.dart';

class AddPlayerScreen extends StatefulWidget {
  AddPlayerScreen(this._teamUid, this._seasonUid);

  final String _teamUid;
  final String _seasonUid;

  @override
  AddPlayerScreenState createState() {
    return new AddPlayerScreenState();
  }
}

class EmailName {
  final GlobalKey<FormFieldState<String>> nameKey =
      new GlobalKey<FormFieldState<String>>();
  InviteTeamData data;
  FocusNode focusNodeEmail = new FocusNode();
  FocusNode focusNodeName = new FocusNode();
}

class AddPlayerScreenState extends State<AddPlayerScreen> {
  final Validations _validations = new Validations();
  List<EmailName> _emailNames = <EmailName>[];
  bool autovalidate = false;
  String _curSeasonUid;

  AddInviteBloc addInviteBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _curSeasonUid = widget._seasonUid;
    addInviteBloc = AddInviteBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _handleSubmit(Team team) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Send the invite, cloud functions will handle the email
      // part of this.
      addInviteBloc.add(InvitePlayersToTeam(
        seasonUid: widget._seasonUid,
        invites: _emailNames.map((b) => b.data),
        teamUid: team.uid,
        teamName: team.name,
      ));
    } else {
      autovalidate = true;
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildForm(SingleTeamBloc singleTeamBloc) {
    List<Widget> rows = <Widget>[];
    Messages messages = Messages.of(context);

    rows.add(
      new DropdownButtonHideUnderline(
        child: new SeasonFormField(
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
      _emailNames.add(new EmailName());
    }
    for (EmailName en in _emailNames) {
      rows.add(
        new EnsureVisibleWhenFocused(
          focusNode: en.focusNodeName,
          child: new TextFormField(
            key: en.nameKey,
            initialValue: '',
            decoration: new InputDecoration(
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
        new EnsureVisibleWhenFocused(
          focusNode: en.focusNodeEmail,
          child: new TextFormField(
            initialValue: '',
            decoration: new InputDecoration(
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
                  _emailNames.add(new EmailName());
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
        new RoleInTeamFormField(
          initialValue: 'none',
          decoration: new InputDecoration(
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

    return new SingleChildScrollView(
      child: new Form(
        autovalidate: autovalidate,
        key: _formKey,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Scrollbar(
              child: new SingleChildScrollView(
                child: new Column(children: rows),
              ),
            ),
            new FlatButton(
              onPressed: () => _handleSubmit(singleTeamBloc.state.team),
              child: new Text(Messages.of(context).addplayer),
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
        appBar: new AppBar(
          title: new Text(Messages.of(context).addplayer),
        ),
        body: BlocListener(
          bloc: addInviteBloc,
          listener: (BuildContext context, AddItemState state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              _showInSnackBar(Messages.of(context).formerror);
            }
          },
          child: BlocBuilder(
            bloc: addInviteBloc,
            builder: (BuildContext context, AddItemState state) =>
                SavingOverlay(
              saving: state is AddItemSaving,
              child: SingleTeamProvider(
                teamUid: widget._teamUid,
                builder:
                    (BuildContext contextl, SingleTeamBloc singleTeamBloc) =>
                        _buildForm(singleTeamBloc),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
