import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/widgets/blocs/singlegameprovider.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:video_player/video_player.dart';
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
  String _description;
  String _youtubeID;
  PickedFile _imageFile;
  PickedFile _videoFile;
  int _selectedIndex = 0;
  YoutubePlayerController _youtubeController;
  VideoPlayerController _videoController;
  bool _invalidUrl = false;

  AddMediaBloc _addMediaBloc;

  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _youtubeIdFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (_selectedIndex == 0) {
        if (_imageFile != null) {
          _showInSnackBar(Messages.of(context).invalidImageFile);
          autoValidate = AutovalidateMode.always;
          _invalidUrl = true;
          return;
        }
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
          playerUid: SeasonPlayerFormField.none,
          mediaType: MediaType.image,
          description: _description,
          imageFile: bytes,
          startAt: start,
        ));
      } else if (_selectedIndex == 1) {
        if (_videoFile != null) {
          _showInSnackBar(Messages.of(context).invalidImageFile);
          autoValidate = AutovalidateMode.always;
          _invalidUrl = true;
          return;
        }
        final bytes = await _videoFile.readAsBytes();

        // Send the invite, cloud functions will handle the email
        // part of this.
        _addMediaBloc.add(AddMediaEventCommit(
          seasonUid: game.seasonUid,
          teamUid: game.teamUid,
          gameUid: game.uid,
          playerUid: SeasonPlayerFormField.none,
          mediaType: MediaType.videoOnDemand,
          description: _description,
          imageFile: bytes,
          startAt: game.sharedData.tzTime,
        ));
      } else {
        var thumb = YoutubePlayer.getThumbnail(videoId: _youtubeID);
        print('Invalid thumbnail $_youtubeID');
        if (thumb == null) {
          _showInSnackBar(Messages.of(context).invalidYoutubeURL);
          _invalidUrl = true;
          return;
        }
        try {
          var data = await NetworkAssetBundle(Uri.parse(thumb)).load('');
          print('Invalid data $_youtubeID');
          if (data == null) {
            _showInSnackBar(Messages.of(context).invalidYoutubeURL);
            _invalidUrl = true;
            return;
          }
          _addMediaBloc.add(
            AddMediaEventCommit(
              seasonUid: game.seasonUid,
              teamUid: game.teamUid,
              gameUid: game.uid,
              playerUid: SeasonPlayerFormField.none,
              mediaType: MediaType.youtubeID,
              description: _description,
              imageFile: data.buffer.asUint8List(),
              youtubeID: _youtubeID,
              startAt: game.sharedData.tzTime,
            ),
          );
        } on FlutterError catch (e) {
          _showInSnackBar(Messages.of(context).invalidYoutubeURL);
          autoValidate = AutovalidateMode.always;
          _invalidUrl = true;
        }
      }
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

  Widget _showVideo() {
    if (_videoFile == null) {
      return Icon(
        Icons.help,
        size: 200,
      );
    }
    if (_videoController == null) {
      _videoController = VideoPlayerController.network(_videoFile.path);
      _videoController.initialize();
    }
    return SizedBox(
      height: 100,
      child: VideoPlayer(
        _videoController,
      ),
    );
  }

  void _pickImage() async {
    final picker = RepositoryProvider.of<ImagePicker>(context);
    if (_selectedIndex == 0) {
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
    } else {
      final img = await picker.getVideo(
        source: ImageSource.gallery,
      );
      if (img != null) {
        setState(() {
          _videoFile = img;
        });
      }
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
        GestureDetector(
          onTap: _pickImage,
          child: SizedBox(
            height: 100,
            child: _showImage(),
          ),
        ),
      );
    } else if (_selectedIndex == 1) {
      rows.add(
        GestureDetector(
          onTap: _pickImage,
          child: SizedBox(
            height: 100,
            child: _showVideo(),
          ),
        ),
      );
    } else if (_selectedIndex == 2) {
      rows.add(
        TextFormField(
          initialValue: _youtubeID != null
              ? 'https://www.youtube.com/watch?v=$_youtubeID'
              : '',
          decoration: InputDecoration(
              icon: const Icon(MdiIcons.video),
              labelText: messages.youtubeLink,
              hintText: messages.youtubeLink),
          minLines: 3,
          maxLines: 5,
          focusNode: _youtubeIdFocusNode,
          keyboardType: TextInputType.url,
          validator: (v) {
            var val = Validations.validateYoutubeUrl(context, v);
            if (val == null && _invalidUrl) {
              return Messages.of(context).invalidUrl;
            }
            return val;
          },
          onChanged: (s) {
            if (Validations.validateYoutubeUrl(context, s) == null) {
              var newS = YoutubePlayer.convertUrlToId(s);
              // Load it or do something.
              if (_youtubeController == null) {
                _youtubeController =
                    YoutubePlayerController(initialVideoId: newS);
              } else {
                _youtubeController.load(newS);
              }
              setState(() {});
            } else if (_youtubeController != null) {
              _youtubeController.pause();
            }
          },
          onSaved: (value) {
            _youtubeID = YoutubePlayer.convertUrlToId(value);
            // See if we can get the id (or if this is an id) for the youtube
            // video
            if (_youtubeID != null) {
              if (_youtubeController == null) {
                _youtubeController =
                    YoutubePlayerController(initialVideoId: _youtubeID);
              } else {
                _youtubeController.load(_youtubeID);
              }
            } else {
              _youtubeController?.dispose();
              _youtubeController = null;
            }
            setState(() {});
          },
        ),
      );
      if (_youtubeController == null) {
        rows.add(
          Icon(MdiIcons.videoPlusOutline, size: 100),
        );
      } else {
        rows.add(
          YoutubePlayer(
            controller: _youtubeController,
            aspectRatio: 16 / 9,
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
          body: SingleChildScrollView(
            child: BlocListener(
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
          ),
          resizeToAvoidBottomInset: true,
          bottomSheet: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: Messages.of(context).imageMediaType,
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.video),
                label: Messages.of(context).video,
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.youtube),
                label: Messages.of(context).youtubeMediaType,
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
