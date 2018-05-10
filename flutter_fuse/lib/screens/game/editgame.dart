import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';
import 'package:flutter_fuse/widgets/games/trainingeditform.dart';
import 'package:flutter_fuse/widgets/games/eventeditform.dart';
import 'package:flutter_fuse/widgets/games/editformbase.dart';

class EditGameScreen extends StatefulWidget {
  final String gameuid;

  EditGameScreen(this.gameuid);

  @override
  EditGameScreenState createState() {
    return new EditGameScreenState(this.gameuid);
  }
}

class EditGameScreenState extends State<EditGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  EditFormBase _gameFormKey;

  EditGameScreenState(String gameUid);

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context) async {
    if (_gameFormKey.validate()) {
      _gameFormKey.save();
      await _gameFormKey.finalGameResult.updateFirestore();
      Navigator.pop(context);
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    Game game = UserDatabaseData.instance.games[widget.gameuid];
    Widget form;
    switch (game.type) {
      case EventType.Game:
        var key = new GlobalKey<GameEditFormState>();
        form = new GameEditForm(game: game, key: key);
        _gameFormKey = key.currentState;
        break;
      case EventType.Event:
        var key = new GlobalKey<TrainingEditFormState>();
        form = new TrainingEditForm(game: game, key: key);
        _gameFormKey = key.currentState;
        break;
      case EventType.Practice:
        var key = new GlobalKey<EventEditFormState>();
        form = new EventEditForm(game: game, key: key);
        _gameFormKey = key.currentState;
        break;
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
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
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        child: form,
      ),
    );
  }
}
