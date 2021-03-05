import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleprofileprovider.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/userimage.dart';

///
/// The scren to edit the profile for the user.
///
class EditProfileScreen extends StatefulWidget {
  /// Constructor.
  EditProfileScreen(this.meUid);

  /// The uid to display.
  final String meUid;

  @override
  _EditProfileScreenState createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _autovalidate = false;
  final Validations _validations = Validations();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Uint8List _imageFile;
  bool _changedImage = false;

  // Details to update.
  String _displayName;
  String _phoneNumber;

  void save() {
    _formKey.currentState.save();
  }

  bool validate() {
    return _formKey.currentState.validate();
  }

  void _selectImage() async {
    var imgFile = await RepositoryProvider.of<ImagePicker>(context).getImage(
        source: ImageSource.gallery, maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      var data = await imgFile.readAsBytes();
      setState(() {
        _imageFile = data;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage(SingleProfileState profileState) {
    if (!_changedImage) {
      return UserImage(profileState.profile.uid);
    }
    return Image.memory(_imageFile);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(BuildContext context, SingleProfileBloc profileBloc) async {
    if (_formKey.currentState.validate() &&
        profileBloc.state is SinglePlayerLoaded) {
      _formKey.currentState.save();
      var state = profileBloc.state;
      var profile = state.profile.rebuild((b) => b
        ..displayName = _displayName
        ..phoneNumber = _phoneNumber);
      profileBloc.add(SingleProfileUpdate(profile: profile, image: _imageFile));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return SingleProfileProvider(
      userUid: authBloc.currentUser.uid,
      builder: (context, profileBloc) => BlocListener(
        cubit: profileBloc,
        listener: (context, profileState) {
          if (profileState is SingleProfileSaveDone ||
              profileState is SingleProfileDeleted) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(Messages.of(context).title),
              key: _scaffoldKey,
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _savePressed(context, profileBloc);
                  },
                  child: Text(
                    Messages.of(context).saveButtonText,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: BlocBuilder(
              cubit: profileBloc,
              builder: (context, profileState) {
                if (profileState is SingleProfileUninitialized) {
                  return LoadingWidget();
                }
                return SavingOverlay(
                  saving: profileState is SingleProfileSaving,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            autovalidateMode: _autovalidate
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            child: DropdownButtonHideUnderline(
                              child: Column(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: _selectImage,
                                    iconSize: (screenSize.width < 500)
                                        ? 120.0
                                        : (screenSize.width / 4) + 12.0,
                                    icon: _buildImage(profileState),
                                  ),
                                  EnsureVisibleWhenFocused(
                                    focusNode: _focusNode,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        icon: const Icon(Icons.person),
                                        hintText: Messages.of(context).name,
                                        labelText: Messages.of(context)
                                            .displaynamehint,
                                      ),
                                      initialValue:
                                          profileState.profile.displayName,
                                      keyboardType: TextInputType.text,
                                      obscureText: false,
                                      validator: (name) {
                                        return _validations.validateName(
                                            context, name);
                                      },
                                      onSaved: (value) {
                                        _displayName = value;
                                      },
                                    ),
                                  ),
                                  EnsureVisibleWhenFocused(
                                    focusNode: _focusNode,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        icon: const Icon(Icons.phone),
                                        hintText:
                                            Messages.of(context).phonenumber,
                                        labelText: Messages.of(context)
                                            .phonenumberhint,
                                      ),
                                      initialValue:
                                          profileState.profile.phoneNumber,
                                      keyboardType: TextInputType.text,
                                      obscureText: false,
                                      validator: (phone) {
                                        return _validations.validatePhone(
                                            context, phone);
                                      },
                                      onSaved: (value) {
                                        _phoneNumber = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
