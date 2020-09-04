import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';

class AddMemberScreen extends StatefulWidget {
  AddMemberScreen(this.clubUid);

  final String clubUid;

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
  String _emailToInvite;
  bool _inviteAsAdmin;
  bool _doingSave = false;
  SingleClubBloc _singleClubBloc;

  @override
  void initState() {
    super.initState();
    _singleClubBloc = SingleClubBloc(
        clubUid: widget.clubUid, clubBloc: BlocProvider.of<ClubBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleClubBloc.close();
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
      if (_singleClubBloc.state.club.isAdmin()) {
        _doingSave = true;
        _singleClubBloc.add(SingleClubInviteMember(
            email: _emailToInvite, admin: _inviteAsAdmin));
      } else {
        _showInSnackBar(Messages.of(context).needtobeadmin);
      }
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildBody() {
    return BlocListener(
      cubit: _singleClubBloc,
      listener: (BuildContext context, SingleClubState state) {
        if (state is SingleClubSaveFailed) {
          _showInSnackBar(Messages.of(context).formerror);
        } else if (state is SingleClubDeleted) {
          Navigator.pop(context);
        } else if (state is SingleClubLoaded) {
          if (_doingSave) {
            Navigator.pop(context);
          }
        }
      },
      child: BlocBuilder(
        cubit: _singleClubBloc,
        builder: (BuildContext context, SingleClubState state) {
          return SavingOverlay(
            saving: state is SingleClubSaving,
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
                      title: Text(state.club.name,
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
                      icon: Icons.person_add,
                      child: new Text(Messages.of(context).administrator),
                      initialValue: false,
                      onSaved: (bool value) => _inviteAsAdmin = value,
                    )
                  ],
                ),
              ),
            ),
          );
        },
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
