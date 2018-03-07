import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';

class EditGameScreen extends StatefulWidget {
  String gameuid;

  EditGameScreen(this.gameuid);

  @override
  EditGameScreenState createState() {
    return new EditGameScreenState(this.gameuid);
  }
}

class EditGameScreenState extends State<EditGameScreen> {
  final Game _game;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<EditGameFormState> _gameFormKey =
      new GlobalKey<EditGameFormState>();

  EditGameScreenState(String gameUid)
      : _game = new Game.copy(UserDatabaseData.instance.games[gameUid]);

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context) async {
    if (await _gameFormKey.currentState.validateAndSaveToFirebase()) {
      Navigator.pop(context);
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: new EditGameForm(_game, _gameFormKey),
        ));
  }
}
