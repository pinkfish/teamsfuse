import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/form/relationshipformfield.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

class EditPlayerScreen extends StatefulWidget {
  EditPlayerScreen({this.playerUid});

  final String playerUid;

  @override
  EditPlayerScreenState createState() {
    return new EditPlayerScreenState();
  }
}

class EditPlayerScreenState extends State<EditPlayerScreen> {
  EditPlayerScreenState();

  Player _player;
  Validations _validations = new Validations();
  File _imageFile;
  bool _changedImage = false;
  bool _autoValidate = false;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _player = new Player.copy(data.players[widget.playerUid]);
  }

  Future<void> _chooseImage() async {
    File imgFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);

    if (imgFile != null) {
      setState(() {
        _imageFile = imgFile;
        _changedImage = true;
      });
    }
  }

  void _onAddPlayerInvite(BuildContext context) {
    Navigator.pushNamed(context, "AddInviteToPlayer/" + widget.playerUid);
  }

  List<Widget> _buildPlayerData() {
    final Size screenSize = MediaQuery.of(context).size;
    List<Widget> ret = <Widget>[];
    Messages messages = Messages.of(context);

    ImageProvider provider;
    if (_imageFile != null) {
      provider = new FileImage(_imageFile);
    } else {
      provider = new CachedNetworkImageProvider(urlNow: _player.photoUrl);
    }
    ret.add(
      new Center(
        child: new GestureDetector(
          onTap: _chooseImage,
          child: new CircleAvatar(
            radius:
                (screenSize.width < 500) ? 60.0 : (screenSize.width / 8) + 12.0,
            backgroundImage: provider,
          ),
        ),
      ),
    );
    ret.add(
      new TextFormField(
        decoration: new InputDecoration(
          labelText: messages.displayname,
          hintText: messages.displaynamehint,
          icon: const Icon(Icons.account_circle),
        ),
        initialValue: _player.name,
        validator: (String value) => _validations.validateName(context, value),
        onSaved: (String name) => _player.name = name,
      ),
    );

    // Add in all the associated users and their relationships.
    print("building dfor ${_player.users}");
    for (PlayerUser user in _player.users.values) {
      //  ret.add(new Item)
      ret.add(
        new DropdownButtonHideUnderline(
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                child: new FutureBuilder<FusedUserProfile>(
                    future: user.getProfile(),
                    builder: (BuildContext context,
                        AsyncSnapshot<FusedUserProfile> data) {
                      if (data.hasData) {
                        return new Text(
                          data.data.displayName,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.subhead,
                        );
                      }
                      return new Text(Messages.of(context).loading);
                    }),
              ),
              new Flexible(
                child: new RelationshipFormField(
                  initialValue: user.relationship,
                  onSaved: (Relationship rel) => user.relationship = rel,
                ),
              ),
            ],
          ),
        ),
      );
    }

    ret.add(new Divider());
    ret.add(
      new FlatButton(
        onPressed: () => _onAddPlayerInvite(context),
        color: Theme.of(context).highlightColor,
        child: new Text(Messages.of(context).addinvite),
      ),
    );

    return ret;
  }

  void _saveData() async {
    setState(() {
      _autoValidate = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_changedImage) {
        Uri uri = await _player.updateImage(_imageFile);
        _player.photoUrl = uri.toString();
      }
      await _player.updateFirestore();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[
          new FlatButton(
            onPressed: _saveData,
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
      body: new Container(
        padding: new EdgeInsets.all(10.0),
        child: new Scrollbar(
          child: new SingleChildScrollView(
            child: new Form(
              autovalidate: _autoValidate,
              key: _formKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildPlayerData(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _saveData,
        child: const Icon(Icons.check),
      ),
    );
  }
}
