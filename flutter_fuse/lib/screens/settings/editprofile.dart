import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen(this.meUid);

  final String meUid;

  @override
  EditProfileScreenState createState() {
    return new EditProfileScreenState(meUid);
  }
}

class EditProfileScreenState extends State<EditProfileScreen> {
  EditProfileScreenState(String meUid)
      : me = new Player.copy(UserDatabaseData.instance.players[meUid]);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNode = new FocusNode();
  File _imageFile;
  bool _changedImage = false;
  UserData _user;
  StreamSubscription<UserData> streamListen;
  final Player me;

  // Details to update.
  String displayName;
  String phoneNumber;

  @override
  void initState() {
    super.initState();
    UserDatabaseData.instance.userAuth.currentUser().then((UserData data) {
      setState(() {
        _user = data;
      });
    });
    streamListen = UserDatabaseData.instance.userAuth
        .onAuthChanged()
        .listen((UserData data) {
      setState(() {
        _user = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamListen.cancel();
  }

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

  Widget _buildImage() {
    if (!_changedImage) {
      return new PlayerImage(playerUid: me.uid);
    }
    return new Image.file(_imageFile);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_changedImage) {
        // Only update in the me player, we don't use the built in photourl.
        await me.updateImage(_imageFile);
      }
      FusedUserProfile profile = _user.profile
          .copyWith(displayName: displayName, phoneNumber: phoneNumber);
      UserDatabaseData.instance.userAuth.updateProfile(_user.uid, profile);
      Navigator.pop(context);
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return new Text('Invalid state');
    }

    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        key: _scaffoldKey,
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              _savePressed(context);
            },
            child: new Text(
              Messages.of(context).savebuttontext,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Form(
                key: _formKey,
                autovalidate: _autovalidate,
                child: new DropdownButtonHideUnderline(
                  child: new Column(
                    children: <Widget>[
                      new IconButton(
                        onPressed: _selectImage,
                        iconSize: (screenSize.width < 500)
                            ? 120.0
                            : (screenSize.width / 4) + 12.0,
                        icon: _buildImage(),
                      ),
                      new EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: new TextFormField(
                          decoration: new InputDecoration(
                            icon: const Icon(Icons.person),
                            hintText: Messages.of(context).displayname,
                            labelText: Messages.of(context).displaynamehint,
                          ),
                          initialValue: _user.profile.displayName,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          validator: (String name) {
                            return _validations.validateName(context, name);
                          },
                          onSaved: (String value) {
                            displayName = value;
                          },
                        ),
                      ),
                      new EnsureVisibleWhenFocused(
                        focusNode: _focusNode,
                        child: new TextFormField(
                          decoration: new InputDecoration(
                            icon: const Icon(Icons.phone),
                            hintText: Messages.of(context).phonenumber,
                            labelText: Messages.of(context).phonenumberhint,
                          ),
                          initialValue: _user.profile.phoneNumber,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          validator: (String phone) {
                            return _validations.validatePhone(context, phone);
                          },
                          onSaved: (String value) {
                            phoneNumber = value;
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
  }
}
