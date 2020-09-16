import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/analytics.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add an admin to the team.
///
class AddAdminScreen extends StatefulWidget {
  /// Constructor
  AddAdminScreen(this._teamUid);
  final String _teamUid;

  @override
  _AddAdminScreenState createState() {
    return _AddAdminScreenState();
  }
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final Validations _validations = Validations();
  final List<String> _emailNames = <String>[];
  bool autovalidate = false;

  AddInviteBloc addInviteBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addInviteBloc = AddInviteBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _handleSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Send the invite, cloud functions will handle the email
      // part of this.
      var teamBloc = BlocProvider.of<TeamBloc>(context);
      for (var en in _emailNames) {
        print("Sending to $en");
        Analytics.analytics.logShare(
            contentType: 'inviteAsAdmin',
            itemId: widget._teamUid,
            method: 'handleSubmit');
        addInviteBloc.add(InviteEventAddAsAdmin(
            teamUid: widget._teamUid,
            email: en,
            teamName: teamBloc.state.getTeam(widget._teamUid).name));
      }
    } else {
      autovalidate = true;
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  void save() {
    _handleSubmit();
  }

  Widget _buildForm() {
    var rows = <Widget>[];
    var messages = Messages.of(context);

    if (_emailNames.length == 0) {
      // Add in the start elements.
      _emailNames.add("");
    }
    for (var i = 0; i < _emailNames.length; i++) {
      var en = _emailNames[i];
      rows.add(
        TextFormField(
          initialValue: '',
          decoration: InputDecoration(
              icon: const Icon(Icons.email),
              labelText: messages.email,
              hintText: messages.playeremailHint),
          validator: (value) {
            return _validations.validateEmail(context, value);
          },
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (value) {
            if (value.isNotEmpty && en.isEmpty && en == _emailNames.last) {
              setState(() {
                _emailNames.add("");
              });
            }
          },
          onSaved: (value) {
            _emailNames[i] = value;
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
          title: Text(Messages.of(context).addadmin),
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
              child: _buildForm(),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: save,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
