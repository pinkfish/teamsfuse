import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/clubs/clubimage.dart';
import '../../widgets/form/switchformfield.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  void _savePressed(SingleClubBloc bloc) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (bloc.state.club.isAdmin()) {
        _doingSave = true;
        bloc.add(SingleClubInviteMember(
            email: _emailToInvite, admin: _inviteAsAdmin));
      } else {
        _showInSnackBar(Messages.of(context).needtobeadmin);
      }
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildBody(SingleClubBloc bloc) {
    return BlocConsumer(
      cubit: bloc,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: widget.clubUid,
      builder: (context, singleCLubBloc) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Messages.of(context).addclubmemebertitle),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _savePressed(singleCLubBloc),
          child: const Icon(Icons.check),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _buildBody(singleCLubBloc),
      ),
    );
  }
}
