import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/form/roleinteamformfield.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../services/validations.dart';

///
/// Edit the details for the player.
///
class EditSeasonPlayerScreen extends StatefulWidget {
  /// COnstructor.
  EditSeasonPlayerScreen({@required this.playerUid, @required this.seasonUid});

  /// The seasonUid to update.
  final String seasonUid;

  /// The playerUid to lookup.
  final String playerUid;

  @override
  _EditSeasonPlayerScreenState createState() {
    return _EditSeasonPlayerScreenState();
  }
}

class _EditSeasonPlayerScreenState extends State<EditSeasonPlayerScreen> {
  SeasonPlayerBuilder _player;
  PlayerBuilder _extraPlayerStuff;
  final Validations _validations = Validations();
  Uint8List _imageFile;
  bool _changedImage = false;
  bool _autoValidate = false;
  SingleTeamSeasonPlayerBloc singleSeasonBloc;
  SinglePlayerBloc singlePlayerBloc;
  String _email = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    singleSeasonBloc = SingleTeamSeasonPlayerBloc(
      seasonUid: widget.seasonUid,
      playerUid: widget.playerUid,
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
    singlePlayerBloc = SinglePlayerBloc(
      playerUid: widget.playerUid,
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
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

  List<Widget> _buildPlayerData(SinglePlayerState singlePlayerState) {
    var screenSize = MediaQuery.of(context).size;
    var ret = <Widget>[];
    var messages = Messages.of(context);

    // Only allow editing of photos and stuf for players without
    // user control.
    if (singlePlayerState.player.playerType == PlayerType.guest ||
        singlePlayerState.player.playerType == PlayerType.seasonGuest ||
        singlePlayerState.player.playerType == PlayerType.opponent) {
      ImageProvider provider;
      if (_imageFile != null) {
        provider = MemoryImage(_imageFile);
      } else if (singlePlayerState.player.photoUrl != null) {
        provider =
            CachedNetworkImageProvider(singlePlayerState.player.photoUrl);
      } else {
        provider = AssetImage('assets/images/defaultavatar2.png');
      }
      ret.add(
        Center(
          child: GestureDetector(
            onTap: _chooseImage,
            child: CircleAvatar(
              radius: (screenSize.width < 500)
                  ? 60.0
                  : (screenSize.width / 8) + 12.0,
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
          initialValue: _extraPlayerStuff.name,
          validator: (value) => _validations.validateName(context, value),
          onSaved: (name) => _extraPlayerStuff.name = name,
        ),
      );

      // For a seasonGuest add in an invite link to make
      // the real.
      if (singlePlayerState.player.playerType == PlayerType.seasonGuest) {
        ret.add(
          TextFormField(
            decoration: InputDecoration(
              labelText: messages.email,
              hintText: messages.playeremailHint,
              icon: const Icon(Icons.email),
            ),
            initialValue: '',
            validator: (value) => value.isNotEmpty
                ? _validations.validateEmail(context, value)
                : null,
            onSaved: (email) => _email = email,
          ),
        );
      }
    }

    ret.add(
      TextFormField(
        decoration: InputDecoration(
          labelText: messages.jersyNumber,
          hintText: messages.jersyNumber,
          icon: const Icon(MdiIcons.tshirtCrew),
        ),
        initialValue: _player.jerseyNumber,
        onSaved: (jersey) => _player.jerseyNumber = jersey,
      ),
    );

    ret.add(
      RoleInTeamFormField(
        initialValue: _player.role.toString(),
        decoration: InputDecoration(
          labelText: messages.jersyNumber,
          hintText: messages.jersyNumber,
          icon: const Icon(MdiIcons.tshirtCrew),
        ),
        onSaved: (role) => _player.role = RoleInTeam.values.firstWhere(
            (v) => role == v.toString(),
            orElse: () => RoleInTeam.NonPlayer),
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
      if (_extraPlayerStuff.playerType == PlayerType.seasonGuest ||
          _extraPlayerStuff.playerType == PlayerType.guest ||
          _extraPlayerStuff.playerType == PlayerType.opponent) {
        if (_email.isNotEmpty) {
          singlePlayerBloc.add(SinglePlayerInviteUser(
            email: _email,
          ));
        }
        singlePlayerBloc.add(SinglePlayerUpdate(
          player: _extraPlayerStuff,
          image: _changedImage ? _imageFile : null,
        ));
      }
      singleSeasonBloc.add(SingleTeamSeasonPlayerUpdate(
        player: _player.build(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
        actions: <Widget>[
          TextButton(
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
        bloc: singlePlayerBloc,
        listener: (context, playerState) {
          if (playerState is SinglePlayerDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, playerState) => BlocConsumer(
          bloc: singleSeasonBloc,
          listener: (context, seasonState) {
            if (seasonState is SingleTeamSeasonPlayerSaveDone) {
              Navigator.pop(context);
            }
            if (seasonState is SingleTeamSeasonPlayerDeleted) {
              Navigator.pop(context);
            }
          },
          builder: (context, seasonState) {
            if (seasonState is SingleTeamSeasonPlayerLoaded &&
                _player == null) {
              _player = seasonState.seasonPlayer.toBuilder();
            }
            if (playerState is SinglePlayerLoaded &&
                _extraPlayerStuff == null) {
              _extraPlayerStuff = playerState.player.toBuilder();
            }

            if (seasonState is SingleTeamSeasonPlayerUninitialized ||
                seasonState is SingleTeamSeasonPlayerDeleted ||
                playerState is SinglePlayerUninitialized ||
                playerState is SinglePlayerDeleted) {
              return LoadingWidget();
            }

            return Container(
              padding: EdgeInsets.all(10.0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Form(
                    autovalidateMode: _autoValidate
                        ? AutovalidateMode.always
                        : AutovalidateMode.onUserInteraction,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveData,
        child: const Icon(Icons.check),
      ),
    );
  }
}
