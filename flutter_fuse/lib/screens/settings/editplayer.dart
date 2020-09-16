import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/form/relationshipformfield.dart';
import '../../widgets/util/username.dart';

class EditPlayerScreen extends StatefulWidget {
  EditPlayerScreen({this.playerUid});

  final String playerUid;

  @override
  EditPlayerScreenState createState() {
    return EditPlayerScreenState();
  }
}

class EditPlayerScreenState extends State<EditPlayerScreen> {
  EditPlayerScreenState();

  PlayerBuilder _player;
  Validations _validations = Validations();
  File _imageFile;
  bool _changedImage = false;
  bool _autoValidate = false;
  SinglePlayerBloc singlePlayerBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    singlePlayerBloc = SinglePlayerBloc(
        playerBloc: BlocProvider.of(context), playerUid: widget.playerUid);
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

  List<Widget> _buildPlayerData(SinglePlayerState singlePlayerState) {
    final Size screenSize = MediaQuery.of(context).size;
    List<Widget> ret = <Widget>[];
    Messages messages = Messages.of(context);

    ImageProvider provider;
    if (_imageFile != null) {
      provider = FileImage(_imageFile);
    } else {
      provider = CachedNetworkImageProvider(singlePlayerState.player.photoUrl);
    }
    ret.add(
      Center(
        child: GestureDetector(
          onTap: _chooseImage,
          child: CircleAvatar(
            radius:
                (screenSize.width < 500) ? 60.0 : (screenSize.width / 8) + 12.0,
            backgroundImage: provider,
          ),
        ),
      ),
    );
    ret.add(
      TextFormField(
        decoration: InputDecoration(
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
    print("building dfor ${_player.usersData}");
    for (String uid in _player.usersData.build().keys) {
      PlayerUserInternal user = _player.usersData[uid];
      //  ret.add(Item)
      ret.add(
        DropdownButtonHideUnderline(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: UserName(
                  userId: uid,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
              Flexible(
                child: RelationshipFormField(
                  initialValue: user.relationship,
                  onSaved: (Relationship rel) => _player.usersData.updateValue(
                      uid,
                      (PlayerUserInternal u) =>
                          u.rebuild((b) => b..relationship = rel)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    ret.add(Divider());
    ret.add(
      FlatButton(
        onPressed: () => _onAddPlayerInvite(context),
        color: Theme.of(context).highlightColor,
        child: Text(Messages.of(context).addinvite),
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
      singlePlayerBloc.add(SinglePlayerUpdate(
          player: _player, image: _changedImage ? _imageFile : null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
        actions: <Widget>[
          FlatButton(
            onPressed: _saveData,
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
      body: BlocProvider(
        create: (BuildContext context) => singlePlayerBloc,
        child: BlocListener(
          cubit: singlePlayerBloc,
          listener: (BuildContext contex, SinglePlayerState playerState) {
            if (playerState is SinglePlayerLoaded) {
              _player = playerState.player.toBuilder();
            }
            if (playerState is SinglePlayerSaveDone) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder(
            cubit: singlePlayerBloc,
            builder: (BuildContext context, SinglePlayerState playerState) =>
                Container(
              padding: EdgeInsets.all(10.0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Form(
                    autovalidate: _autoValidate,
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildPlayerData(playerState),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveData,
        child: const Icon(Icons.check),
      ),
    );
  }
}
