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
    if (mess.length > 0) {
      var playerBloc = BlocProvider.of<PlayerBloc>(context);

      game.add(SingleGameAddGameLog(
          log: GameLog((b) => b
            ..type = GameLogType.Message
            ..message = mess
            ..displayName = playerBloc.state.me.name
            ..uid = playerBloc.state.me.uid)));
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
