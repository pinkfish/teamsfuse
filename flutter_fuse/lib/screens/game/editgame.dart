import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singlegameprovider.dart';
import 'package:flutter_fuse/widgets/games/editformbase.dart';
import 'package:flutter_fuse/widgets/games/eventeditform.dart';
import 'package:flutter_fuse/widgets/games/gameeditform.dart';
import 'package:flutter_fuse/widgets/games/trainingeditform.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class EditGameScreen extends StatefulWidget {
  EditGameScreen(this.gameuid);

  final String gameuid;

  @override
  EditGameScreenState createState() {
    return new EditGameScreenState();
  }
}

class EditGameScreenState extends State<EditGameScreen> {
  EditGameScreenState();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<GameEditFormState> _gameFormKey =
      new GlobalKey<GameEditFormState>();
  GlobalKey<TrainingEditFormState> _trainingFormKey =
      new GlobalKey<TrainingEditFormState>();
  GlobalKey<EventEditFormState> _eventFormKey =
      new GlobalKey<EventEditFormState>();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context, SingleGameBloc gameBloc) async {
    print('save pressed');
    Game game = gameBloc.currentState.game;
    EditFormBase baseForm;
    switch (game.sharedData.type) {
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
      baseForm.save();
      print("updating firestore");
      gameBloc
          .dispatch(SingleGameUpdate(game: baseForm.finalGameResult.build()));
      print('finished update');
    } else {
      print('error?');
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: widget.gameuid,
      builder: (BuildContext context, SingleGameBloc gameBloc) => BlocListener(
        bloc: gameBloc,
        listener: (BuildContext context, SingleGameState state) {
          if (state is SingleGameSaveFailed) {
            print('error?');
            _showInSnackBar(Messages.of(context).formerror);
          }
          if (state is SingleGameSaveDone) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: new Text(Messages.of(context).title),
          ),
          body: new Container(
            padding: new EdgeInsets.all(16.0),
            child: BlocBuilder(
                bloc: gameBloc,
                builder: (BuildContext context, SingleGameState gameState) {
                  Widget form;
                  switch (gameState.game.sharedData.type) {
                    case EventType.Game:
                      form = new GameEditForm(
                          game: gameState.game, key: _gameFormKey);
                      break;
                    case EventType.Event:
                      form = new EventEditForm(
                          game: gameState.game, key: _eventFormKey);
                      break;
                    case EventType.Practice:
                      form = new TrainingEditForm(
                          game: gameState.game, key: _trainingFormKey);
                      break;
                  }
                  return SavingOverlay(
                    saving: gameState is SingleGameSaving,
                    child: form,
                  );
                }),
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: () => _savePressed(context, gameBloc),
            child: const Icon(Icons.check),
          ),
        ),
      ),
    );
  }
}
