import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class MessageSendBox extends StatelessWidget {
  final TextEditingController _textController = new TextEditingController();
  final Game game;

  MessageSendBox(this.game);

  void _sendMessage(String mess) {
    mess = mess.trim();
    if (mess.length > 0) {
      print("Adding log for ${game.uid}");
      game.addGameLog(new GameLog(
          type: GameLogType.Message,
          message: mess,
          uid: UserDatabaseData.instance.userUid,
          displayName: UserDatabaseData.instance.mePlayer.name));
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new TextField(
      controller: _textController,
      decoration: new InputDecoration(
        suffixIcon: const Icon(Icons.send),
        labelText: Messages.of(context).message,
        fillColor: Colors.white,
        filled: true,
      ),
      keyboardType: TextInputType.text,
      onSubmitted: (String str) => _sendMessage(str),
    );
  }
}
