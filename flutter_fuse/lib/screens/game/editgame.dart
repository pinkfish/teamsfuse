import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singlegameprovider.dart';
import '../../widgets/games/editformbase.dart';
import '../../widgets/games/eventeditform.dart';
import '../../widgets/games/gameeditform.dart';
import '../../widgets/games/trainingeditform.dart';
import '../../widgets/util/loading.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(BuildContext context, SingleGameBloc gameBloc) async {
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
        break;
    }
    if (baseForm.validate()) {
      baseForm.save();
      gameBloc.add(SingleGameUpdate(
          game: baseForm.finalGameResult.build(), updateShared: true));
    } else {
      _showInSnackBar(Messages.of(context).formError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: widget.gameuid,
      builder: (context, gameBloc) => BlocListener(
        bloc: gameBloc,
        listener: (context, state) {
          if (state is SingleGameSaveFailed) {
            _showInSnackBar(Messages.of(context).formError);
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
                bloc: gameBloc,
                builder: (context, gameState) {
                  Widget form;
                  if (gameState is SingleGameUninitialized) {
                    return LoadingWidget();
                  }
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
