import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class MessageSendBox extends StatelessWidget {
  MessageSendBox(this.game);

  final TextEditingController _textController = TextEditingController();
  final SingleGameBloc game;

  void _sendMessage(BuildContext context, String mess) {
    mess = mess.trim();
    if (mess.length > 0) {
      PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
      print("Adding log for ${game.state.game.uid}");

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
      onSubmitted: (String str) => _sendMessage(context, str),
    );
  }
}
