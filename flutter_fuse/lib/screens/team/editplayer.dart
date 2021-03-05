import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/form/relationshipformfield.dart';
import '../../widgets/util/username.dart';

///
/// Edit the details for the player.
///
class EditPlayerScreen extends StatefulWidget {
  /// COnstructor.
  EditPlayerScreen({this.playerUid});

  /// The playerUid to lookup.
  final String playerUid;

  @override
  _EditPlayerScreenState createState() {
    return _EditPlayerScreenState();
  }
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  PlayerBuilder _player;
  final Validations _validations = Validations();
  Uint8List _imageFile;
  bool _changedImage = false;
  bool _autoValidate = false;
  SinglePlayerBloc singlePlayerBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    singlePlayerBloc = SinglePlayerBloc(
        playerUid: widget.playerUid,
        db: RepositoryProvider.of<DatabaseUpdateModel>(context));
  }

  Future<void> _chooseImage() async {
    var imgFile = await RepositoryProvider.of<ImagePicker>(context).getImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);

    if (imgFile != null) {
      var data = await imgFile.readAsBytes();
      setState(() {
        _imageFile = data;
        _changedImage = true;
      });
    }
  }

  void _onAddPlayerInvite(BuildContext context) {
    Navigator.pushNamed(context, 'AddInviteToPlayer/${widget.playerUid}');
  }

  List<Widget> _buildPlayerData(SinglePlayerState singlePlayerState) {
    var screenSize = MediaQuery.of(context).size;
    var ret = <Widget>[];
    var messages = Messages.of(context);

    ImageProvider provider;
    if (_imageFile != null) {
      provider = MemoryImage(_imageFile);
    } else if (singlePlayerState.player.photoUrl != null) {
      provider = CachedNetworkImageProvider(singlePlayerState.player.photoUrl);
    } else {
      provider = AssetImage('assets/images/defaultavatar2.png');
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
          labelText: messages.name,
          hintText: messages.displaynamehint,
          icon: const Icon(Icons.account_circle),
        ),
        initialValue: _player.name,
        validator: (value) => _validations.validateName(context, value),
        onSaved: (name) => _player.name = name,
      ),
    );

    // Add in all the associated users and their relationships.
    for (var uid in _player.usersData.build().keys) {
      var user = _player.usersData[uid];
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
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Flexible(
                child: RelationshipFormField(
                  initialValue: user.relationship,
                  onSaved: (rel) => _player.usersData.updateValue(
                      uid, (u) => u.rebuild((b) => b..relationship = rel)),
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
        child: Text(Messages.of(context).addInviteButton),
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
              Messages.of(context).saveButtonText,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocConsumer(
        cubit: singlePlayerBloc,
        listener: (contex, playerState) {
          if (playerState is SinglePlayerLoaded) {
            _player = playerState.player.toBuilder();
          }
          if (playerState is SinglePlayerSaveDone) {
            Navigator.pop(context);
          }
          if (playerState is SinglePlayerDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, playerState) {
          if (playerState is SinglePlayerUninitialized ||
              playerState is SinglePlayerDeleted) {
            return LoadingWidget();
          }
          return Container(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveData,
        child: const Icon(Icons.check),
      ),
    );
  }
}
