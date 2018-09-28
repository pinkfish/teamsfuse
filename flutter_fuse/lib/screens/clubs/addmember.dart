import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';

class AddMemberScreen extends StatefulWidget {
  final String clubUid;

  AddMemberScreen(this.clubUid);

  @override
  AddMemberScreenState createState() {
    return new AddMemberScreenState();
  }
}

class AddMemberScreenState extends State<AddMemberScreen> {
  final FocusNode _nameField = new FocusNode();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final Validations validations = new Validations();
  bool _autoValidate = false;
  bool _saving = false;
  String _emailToInvite;
  bool _inviteAsAdmin;
  Club _club;

  void initState() {
    super.initState();
    _club = UserDatabaseData.instance.clubs[widget.clubUid];
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _saving = true;
      });
      try {
        if (UserDatabaseData.instance.clubs.containsKey(widget.clubUid)) {
          Club club = UserDatabaseData.instance.clubs[widget.clubUid];
          if (club.isAdmin()) {
            await club.invite(_emailToInvite, _inviteAsAdmin);
            Navigator.pop(context);
          } else {
            _showInSnackBar(Messages.of(context).needtobeadmin);
          }
        }
      } finally {
        setState(() {
          _saving = false;
        });
      }
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildBody() {
    return new SavingOverlay(
      saving: _saving,
      child: new SingleChildScrollView(
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new ListTile(
                leading: ClubImage(
                  width: 40.0,
                  height: 40.0,
                  clubUid: widget.clubUid,
                ),
                title: Text(_club.name,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
              new ListTile(
                leading: const Icon(Icons.email),
                title: new EnsureVisibleWhenFocused(
                  child: new TextFormField(
                    decoration: new InputDecoration(
                        labelText: Messages.of(context).email,
                        hintText: Messages.of(context).playeremailHint),
                    initialValue: "",
                    validator: (String value) =>
                        validations.validateEmail(context, value),
                    onSaved: (String value) => _emailToInvite = value,
                  ),
                  focusNode: _nameField,
                ),
              ),
              new SwitchFormField(
                icon:  Icons.person_add,
                child: new Text(Messages.of(context).administrator),
                initialValue: false,
                onSaved: (bool value) => _inviteAsAdmin = value,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).addclubmemebertitle),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _savePressed,
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
