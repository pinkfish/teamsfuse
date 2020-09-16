import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/blocs/singleprofileprovider.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/userimage.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen(this.meUid);

  final String meUid;

  @override
  EditProfileScreenState createState() {
    return EditProfileScreenState();
  }
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = Validations();
  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
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
    File imgFile = await ImagePicker.pickImage(
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
      FusedUserProfile profile = profileState.profile.rebuild((b) => b
        ..displayName = _displayName
        ..phoneNumber = _phoneNumber);
      profileBloc.add(SingleProfileUpdate(profile: profile, image: _imageFile));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    var authBloc = BlocProvider.of<AuthenticationBloc>(context);
    return SingleProfileProvider(
      userUid: authBloc.currentUser.uid,
      builder: (BuildContext context, SingleProfileBloc profileBloc) =>
          BlocListener(
        cubit: profileBloc,
        listener: (BuildContext context, SingleProfileState profileState) {
          if (profileState is SingleProfileSaveDone ||
              profileState is SingleProfileDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: profileBloc,
          builder: (BuildContext context, SingleProfileState profileState) {
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
                          .subhead
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
                                    validator: (String name) {
                                      return _validations.validateName(
                                          context, name);
                                    },
                                    onSaved: (String value) {
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
                                    validator: (String phone) {
                                      return _validations.validatePhone(
                                          context, phone);
                                    },
                                    onSaved: (String value) {
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
