import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleseasonprovider.dart';
import '../../widgets/form/gameformfield.dart';
import '../../widgets/form/seasonplayerformfield.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Add a media to the team and season and game.
///
class AddMediaScreen extends StatefulWidget {
  /// Constructor.
  AddMediaScreen(this._teamUid, this._seasonUid);

  final String _teamUid;
  final String _seasonUid;

  @override
  _AddMediaScreenState createState() {
    return _AddMediaScreenState();
  }
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  AutovalidateMode autovalidate = AutovalidateMode.disabled;
  String _curGameUid;
String _curPlayerUid;
  String _description;
  PickedFile _imageFile;

  AddMediaBloc _addMediaBloc;

  final FocusNode _descriptionFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _curGameUid = GameFormField.none;
_curPlayerUid = SeasonPlayerFormField.none;
    _addMediaBloc = AddMediaBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      crashes: RepositoryProvider.of<AnalyticsSubsystem>(context),
    );
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  Future<void> _handleSubmit(Season season) async {
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
        seasonUid: widget._seasonUid,
        teamUid: widget._teamUid,
        gameUid: _curGameUid,
        playerUid: _curPlayerUid,
        mediaType: MediaType.image,
        description: _description,
        imageFile: bytes,
        startAt: start,
      ));
    } else {
      autovalidate = AutovalidateMode.always;
      _showInSnackBar(Messages.of(context).formerror);
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
    final img = await picker.getImage(source: ImageSource.gallery,maxHeight:1024, maxWidth:1024,);
    if (img != null) {
      setState(() {
        _imageFile = img;
      });
    }
  }

  Widget _buildForm(SingleSeasonBloc singleSeasonBloc) {
    final rows = <Widget>[];
    final messages = Messages.of(context);

    rows.add(
      DropdownButtonHideUnderline(
        child: GameFormField(
          initialValue: _curGameUid,
          seasonBloc: singleSeasonBloc,
          includeNone: true,
          onSaved: (value) {
            _curGameUid = value;
          },
        ),
      ),
    );

    rows.add(
      DropdownButtonHideUnderline(
        child: SeasonPlayerFormField(
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
        maxLines:5,
        focusNode: _descriptionFocusNode,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          _description = value;
        },
      ),
    );
    rows.add(

      GestureDetector(child: SizedBox(height: 100, child:

        _showImage(),
      ),onTap: _pickImage,
      ),
    );

    return SingleChildScrollView(
      child: Form(
        autovalidateMode: autovalidate,
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          SingleChildScrollView(
                child: Column(children: rows),
              ),

            BlocBuilder(
              cubit: singleSeasonBloc,
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
                      onPressed: () =>
                          _handleSubmit(singleSeasonBloc.state.season),
                      child: Text(Messages.of(context).addButton),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _addMediaBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(Messages.of(context).addMediaItem),
        ),
        body: BlocListener(
          cubit: _addMediaBloc,
          listener: (context, state) {
            if (state is AddItemDone) {
              Navigator.pop(context);
            }
            if (state is AddItemSaveFailed) {
              _showInSnackBar(Messages.of(context).formerror);
            }
          },
          child: BlocBuilder(
            cubit: _addMediaBloc,
            builder: (context, state) => SavingOverlay(
              saving: state is AddItemSaving,
              child: SingleSeasonProvider(
                seasonUid: widget._seasonUid,
                builder: (context, singleSeasonBloc) =>
                    _buildForm(singleSeasonBloc),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
