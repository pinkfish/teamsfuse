import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/widgets/blocs/singlegameprovider.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleseasonprovider.dart';
import '../../widgets/form/seasonplayerformfield.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add a media to the team and season and game.
///
class AddGameMediaScreen extends StatefulWidget {
  /// Constructor.
  AddGameMediaScreen(this._gameUid);

  final String _gameUid;

  @override
  _AddGameMediaScreenState createState() {
    return _AddGameMediaScreenState();
  }
}

class _AddGameMediaScreenState extends State<AddGameMediaScreen> {
  AutovalidateMode autoValidate = AutovalidateMode.disabled;
  String _curPlayerUid;
  String _description;
  String _youtubeID;
  PickedFile _imageFile;
  int _selectedIndex = 0;
  YoutubePlayerController _youtubeController;

  AddMediaBloc _addMediaBloc;

  final FocusNode _descriptionFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _curPlayerUid = SeasonPlayerFormField.none;
    _addMediaBloc = AddMediaBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      crashes: RepositoryProvider.of<AnalyticsSubsystemImpl>(context),
    );
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  Future<void> _handleSubmit(Game game) async {
    if (_formKey.currentState.validate() && _imageFile != null) {
      _formKey.currentState.save();

      final bytes = await _imageFile.readAsBytes();
      final exif = await readExifFromBytes(bytes);
      DateTime start;
      if (exif['Image DateTime'] != null) {
        print(exif['Image DateTime']);
        print('bong');
      }
      print(exif);

      // Send the invite, cloud functions will handle the email
      // part of this.
      _addMediaBloc.add(AddMediaEventCommit(
        seasonUid: game.seasonUid,
        teamUid: game.teamUid,
        gameUid: game.uid,
        playerUid: _curPlayerUid,
        mediaType: MediaType.image,
        description: _description,
        imageFile: bytes,
        startAt: start,
      ));
    } else {
      autoValidate = AutovalidateMode.always;
      _showInSnackBar(Messages.of(context).formError);
    }
  }

  Widget _showImage() {
    if (_imageFile == null) {
      return Icon(
        Icons.help,
        size: 200,
      );
    }
    return Image.file(
      File(_imageFile.path),
      height: 200,
      width: 200,
    );
  }

  void _pickImage() async {
    final picker = RepositoryProvider.of<ImagePicker>(context);
    final img = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 95,
    );
    if (img != null) {
      setState(() {
        _imageFile = img;
      });
    }
  }

  Widget _buildForm(
      SingleGameBloc singleGameBloc, SingleSeasonBloc singleSeasonBloc) {
    final rows = <Widget>[];
    final messages = Messages.of(context);

    rows.add(Padding(
      padding: EdgeInsets.all(10.0),
      child: GameCard(
        gameUid: widget._gameUid,
        showButtons: false,
      ),
    ));

    rows.add(
      DropdownButtonHideUnderline(
        child: SeasonPlayerFormField(
          decoration: InputDecoration(
              icon: const Icon(Icons.people),
              labelText: messages.players,
              hintText: messages.players),
          initialValue: _curPlayerUid ?? 'none',
          seasonBloc: singleSeasonBloc,
          includeNone: true,
          onSaved: (value) {
            _curPlayerUid = value;
          },
        ),
      ),
    );

    rows.add(
      TextFormField(
        initialValue: '',
        decoration: InputDecoration(
            icon: const Icon(Icons.text_fields),
            labelText: messages.description,
            hintText: messages.description),
        minLines: 3,
        maxLines: 5,
        focusNode: _descriptionFocusNode,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          _description = value;
        },
      ),
    );
    if (_selectedIndex == 0) {
      rows.add(
        Expanded(
          child: GestureDetector(
            onTap: _pickImage,
            child: SizedBox(
              height: 100,
              child: _showImage(),
            ),
          ),
        ),
      );
    } else {
      rows.add(
        TextFormField(
          initialValue: '',
          decoration: InputDecoration(
              icon: const Icon(MdiIcons.video),
              labelText: messages.youtubeLink,
              hintText: messages.youtubeLink),
          minLines: 3,
          maxLines: 5,
          focusNode: _descriptionFocusNode,
          keyboardType: TextInputType.url,
          validator: (v) {
            var id = YoutubePlayer.convertUrlToId(v);
            if (id == null) {
              return Messages.of(context).invalidYoutubeURL;
            }
            return null;
          },
          onSaved: (value) {
            _youtubeID = YoutubePlayer.convertUrlToId(value);
            // See if we can get the id (or if this is an id) for the youtube
            // video
            if (_youtubeID != null) {
              if (_youtubeController != null) {
                _youtubeController =
                    YoutubePlayerController(initialVideoId: _youtubeID);
              } else {
                _youtubeController.load(_youtubeID);
              }
            }
            setState(() {});
          },
        ),
      );
      if (_youtubeController == null) {
        rows.add(
          Expanded(
            child: Icon(MdiIcons.videoPlusOutline, size: 100),
          ),
        );
      } else {
        rows.add(
          Expanded(
            child: YoutubePlayer(
              controller: _youtubeController,
              aspectRatio: 16 / 9,
            ),
          ),
        );
      }
    }

    return Form(
      autovalidateMode: autoValidate,
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...rows,
          BlocBuilder(
            bloc: singleSeasonBloc,
            builder: (context, seasonState) {
              if (seasonState is SingleSeasonUninitialized) {
                return TextButton(
                  onPressed: null,
                  child: Text(Messages.of(context).loading),
                );
              }
              if (!seasonState.loadedGames) {
                singleSeasonBloc.add(
                  SingleSeasonLoadGames(),
                );
              }
              return ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () => _handleSubmit(singleGameBloc.state.game),
                    child: Text(Messages.of(context).addButton),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _addMediaBloc,
      child: SingleGameProvider(
        gameUid: widget._gameUid,
        builder: (context, singleGameBloc) => Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(Messages.of(context).addMediaItem),
            actions: [
              TextButton(
                onPressed: () => _handleSubmit(singleGameBloc.state.game),
                child: Text(
                  MaterialLocalizations.of(context).saveButtonLabel,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          body: BlocListener(
            bloc: _addMediaBloc,
            listener: (context, state) {
              if (state is AddItemDone) {
                Navigator.pop(context);
              }
              if (state is AddItemSaveFailed) {
                _showInSnackBar(Messages.of(context).formError);
              }
            },
            child: BlocBuilder(
              bloc: _addMediaBloc,
              builder: (context, state) => SavingOverlay(
                saving: state is AddItemSaving,
                child: BlocBuilder(
                  bloc: singleGameBloc,
                  builder: (context, gameState) {
                    if (gameState is SingleGameUninitialized) {
                      return LoadingWidget();
                    }

                    return SingleSeasonProvider(
                      seasonUid: gameState.game.seasonUid,
                      builder: (context, singleSeasonBloc) =>
                          _buildForm(singleGameBloc, singleSeasonBloc),
                    );
                  },
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: Messages.of(context).imageMediaType,
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.video),
                label: Messages.of(context).videoMediaType,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).accentColor,
            onTap: (index) => setState(() {
              _selectedIndex = index;
            }),
          ),
        ),
      ),
    );
  }
}
