import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  File _imageFile;
  bool _changedImage = false;
  StreamSubscription<UserData> streamListen;

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
    var imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage(SingleProfileState profileState) {
    if (!_changedImage) {
      return UserImage(profileState.profile);
    }
    return Image.file(_imageFile);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(BuildContext context, SingleProfileState profileState,
      SingleProfileBloc profileBloc) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var profile = profileState.profile.rebuild((b) => b
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
        child: BlocBuilder(
          cubit: profileBloc,
          builder: (context, profileState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(Messages.of(context).title),
                key: _scaffoldKey,
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      _savePressed(context, profileState, profileBloc);
                    },
                    child: Text(
                      Messages.of(context).savebuttontext,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: SavingOverlay(
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
                          autovalidate: _autovalidate,
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
                                      hintText:
                                          Messages.of(context).displayname,
                                      labelText:
                                          Messages.of(context).displaynamehint,
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
                                      labelText:
                                          Messages.of(context).phonenumberhint,
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
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    streamListen.cancel();
    super.dispose();
  }
}
