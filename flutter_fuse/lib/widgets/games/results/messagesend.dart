import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';

///
/// Box to send a message to the others watching.
///
class MessageSendBox extends StatelessWidget {
  /// Constructor.
  MessageSendBox(this.game);

  final TextEditingController _textController = TextEditingController();

  /// Game to send the message to.
  final SingleGameBloc game;

  void _sendMessage(BuildContext context, String mess) {
    mess = mess.trim();
    if (mess.isNotEmpty) {
      var playerBloc = BlocProvider.of<PlayerBloc>(context);
      var undoBloc = BlocProvider.of<GameEventUndoStack>(context);
      undoBloc.addEvent(
          GameEvent((b) => b
            ..type = GameEventType.Message
            ..message = mess
            ..playerUid = playerBloc.state.me.uid
            ..uid = playerBloc.state.me.uid),
          false);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.send),
        labelText: Messages.of(context).message,
        fillColor: Colors.white,
        filled: true,
      ),
      keyboardType: TextInputType.text,
      onSubmitted: (str) => _sendMessage(context, str),
    );
  }
}
