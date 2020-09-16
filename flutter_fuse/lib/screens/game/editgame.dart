import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singlegameprovider.dart';
import '../../widgets/games/editformbase.dart';
import '../../widgets/games/eventeditform.dart';
import '../../widgets/games/gameeditform.dart';
import '../../widgets/games/trainingeditform.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Edit the specific game.
///
class EditGameScreen extends StatefulWidget {
  /// Constructor.
  EditGameScreen(this.gameuid);

  /// The uid of the game to edit.
  final String gameuid;

  @override
  _EditGameScreenState createState() {
    return _EditGameScreenState();
  }
}

class _EditGameScreenState extends State<EditGameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<GameEditFormState> _gameFormKey =
      GlobalKey<GameEditFormState>();
  final GlobalKey<TrainingEditFormState> _trainingFormKey =
      GlobalKey<TrainingEditFormState>();
  final GlobalKey<EventEditFormState> _eventFormKey =
      GlobalKey<EventEditFormState>();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(BuildContext context, SingleGameBloc gameBloc) async {
    print('save pressed');
    var game = gameBloc.state.game;
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
      gameBloc.add(SingleGameUpdate(game: baseForm.finalGameResult.build()));
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
      builder: (context, gameBloc) => BlocListener(
        cubit: gameBloc,
        listener: (context, state) {
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
          appBar: AppBar(
            title: Text(Messages.of(context).title),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            child: BlocBuilder(
                cubit: gameBloc,
                builder: (context, gameState) {
                  Widget form;
                  switch (gameState.game.sharedData.type) {
                    case EventType.Game:
                      form =
                          GameEditForm(game: gameState.game, key: _gameFormKey);
                      break;
                    case EventType.Event:
                      form = EventEditForm(
                          game: gameState.game, key: _eventFormKey);
                      break;
                    case EventType.Practice:
                      form = TrainingEditForm(
                          game: gameState.game, key: _trainingFormKey);
                      break;
                  }
                  return SavingOverlay(
                    saving: gameState is SingleGameSaving,
                    child: form,
                  );
                }),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _savePressed(context, gameBloc),
            child: const Icon(Icons.check),
          ),
        ),
      ),
    );
  }
}
