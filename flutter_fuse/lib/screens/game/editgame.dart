import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';
import 'package:flutter_fuse/widgets/games/trainingeditform.dart';
import 'package:flutter_fuse/widgets/games/eventeditform.dart';
import 'package:flutter_fuse/widgets/games/editformbase.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

class EditGameScreen extends StatefulWidget {
  final String gameuid;

  EditGameScreen(this.gameuid);

  @override
  EditGameScreenState createState() {
    return new EditGameScreenState();
  }
}

class EditGameScreenState extends State<EditGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<GameEditFormState> _gameFormKey =
      new GlobalKey<GameEditFormState>();
  GlobalKey<TrainingEditFormState> _trainingFormKey =
      new GlobalKey<TrainingEditFormState>();
  GlobalKey<EventEditFormState> _eventFormKey =
      new GlobalKey<EventEditFormState>();
  bool _saving = false;

  EditGameScreenState();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context) async {
    print('save pressed');
    Game game = UserDatabaseData.instance.gamesCache[widget.gameuid];
    EditFormBase baseForm;
    switch (game.type) {
      case EventType.Game:
        baseForm = _gameFormKey.currentState;
        break;
      case EventType.Event:
        baseForm = _eventFormKey.currentState;
        break;
      case EventType.Practice:
        baseForm = _trainingFormKey.currentState;
        print('${_trainingFormKey.currentState} $_eventFormKey $_gameFormKey');
        break;
    }
    if (baseForm.validate()) {
      setState(() {
        _saving = true;
      });
      baseForm.save();
      print("updating firestore");
      await baseForm.finalGameResult.updateFirestore();
      print('finished update');
      setState(() {
        _saving = false;
      });
      Navigator.pop(context);
    } else {
      print('error?');
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    Game game = UserDatabaseData.instance.gamesCache[widget.gameuid];
    Widget form;
    switch (game.type) {
      case EventType.Game:
        form = new GameEditForm(game: game, key: _gameFormKey);
        break;
      case EventType.Event:
        form = new EventEditForm(game: game, key: _eventFormKey);
        break;
      case EventType.Practice:
        form = new TrainingEditForm(game: game, key: _trainingFormKey);
        break;
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        child: new SavingOverlay(
          saving: _saving,
          child: form,
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(context),
        child: const Icon(Icons.check),
      ),
    );
  }
}
