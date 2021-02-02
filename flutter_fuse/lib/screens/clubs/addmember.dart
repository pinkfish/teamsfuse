import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/form/switchformfield.dart';
import '../../widgets/clubs/clubimage.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add a member to the league screen.
///
class AddMemberScreen extends StatefulWidget {
  /// Main constructor.
  AddMemberScreen(this.clubUid);

  ///
  /// The club uid to add members too.
  ///
  final String clubUid;

  @override
  _AddMemberScreenState createState() {
    return _AddMemberScreenState();
  }
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final FocusNode _nameField = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final Validations validations = Validations();
  final AutovalidateMode _autoValidate = AutovalidateMode.disabled;
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
      SnackBar(
        content: Text(value),
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
      listener: (context, state) {
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
        builder: (context, state) {
          return SavingOverlay(
            saving: state is SingleClubSaving,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      leading: ClubImage(
                        width: 40.0,
                        height: 40.0,
                        clubUid: widget.clubUid,
                      ),
                      title: Text(state.club.name,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: EnsureVisibleWhenFocused(
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: Messages.of(context).email,
                              hintText: Messages.of(context).playeremailHint),
                          initialValue: "",
                          validator: (value) =>
                              validations.validateEmail(context, value),
                          onSaved: (value) => _emailToInvite = value,
                        ),
                        focusNode: _nameField,
                      ),
                    ),
                    SwitchFormField(
                      icon: Icons.person_add,
                      child: Text(Messages.of(context).administrator),
                      initialValue: false,
                      onSaved: (value) => _inviteAsAdmin = value,
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Messages.of(context).addclubmemebertitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePressed,
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
