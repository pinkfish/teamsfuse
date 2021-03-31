import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

import '../../services/messages.dart';
import 'gamecard.dart';

///
/// Shows a dialog to delete the game.
///
Future<bool> deleteGameDialog(
    BuildContext context, SingleGameBloc gameBloc) async {
  var mess = Messages.of(context);
  var game = gameBloc.state.game;

  var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(mess.deleteGame(game.sharedData)),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: GameCard(gameUid: game.uid),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
          ],
        );
      });
  if (result) {
    gameBloc.add(SingleGameDelete());
  }
  return result;
}
