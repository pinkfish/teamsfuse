import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:flutter_fuse/widgets/util/playerimage.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class EditProfileScreen extends StatefulWidget {
  final String meUid;
  EditProfileScreen(this.meUid);

  @override
  EditProfileScreenState createState() {
    return new EditProfileScreenState(this.meUid);
  }
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool _autovalidate = false;
  Validations _validations = new Validations();
  ScrollController _scrollController = new ScrollController();
  FocusNode _focusNode = new FocusNode();
  File _imageFile;
  bool _changedImage = false;
  UserData user;
  StreamSubscription streamListen;
  final Player me;

  EditProfileScreenState(String meUid)
      : me = new Player.copy(UserDatabaseData.instance.players[meUid]) {
    UserAuth.instance.currentUser().then((UserData data) {
      this.user = new UserData.copy(data);
    });
    streamListen = UserAuth.instance.onAuthChanged().listen((UserData data) {
      setState(() {
        this.user = new UserData.copy(data);
      });
    });
  }

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
    File imgFile =
        await ImagePicker.pickImage(maxHeight: 150.0, maxWidth: 150.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  Widget _buildImage() {
    if (!_changedImage) {
      return new PlayerImage(me.uid);
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
        Uri photoUrl = await me.updateImage(_imageFile);
        user.photoUrl = photoUrl.toString();
      }
      await UserAuth.instance.updateProfile(user);
      Navigator.pop(context);
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget build(BuildContext context) {
    if (user == null) {
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
                  this._savePressed(context);
                },
                child: new Text(Messages.of(context).savebuttontext,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.white))),
          ],
        ),
        body: new SingleChildScrollView(
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
                            onPressed: this._selectImage,
                            iconSize: (screenSize.width < 500)
                                ? 120.0
                                : (screenSize.width / 4) + 12.0,
                            icon: this._buildImage(),
                          ),
                          new EnsureVisibleWhenFocused(
                            focusNode: _focusNode,
                            child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(Icons.person),
                                  hintText: Messages.of(context).displayname,
                                  labelText:
                                      Messages.of(context).displaynamehint,
                                ),
                                initialValue: user.displayName,
                                keyboardType: TextInputType.text,
                                obscureText: false,
                                onSaved: (String value) {
                                  user.displayName = value;
                                }),
                          ),
                          new EnsureVisibleWhenFocused(
                            focusNode: _focusNode,
                            child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(Icons.phone),
                                  hintText: Messages.of(context).phonenumber,
                                  labelText:
                                  Messages.of(context).phonenumberhint,
                                ),
                                initialValue: user.phoneNumber,
                                keyboardType: TextInputType.text,
                                obscureText: false,
                                onSaved: (String value) {
                                  user.displayName = value;
                                }),
                          ),
                        ],
                      )))
                ])));
  }
}
