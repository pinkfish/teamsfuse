import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'gamecard.dart';

Future<bool> deleteGameDialog(
    BuildContext context, SingleGameBloc gameBloc) async {
  Messages mess = Messages.of(context);
  Game game = gameBloc.state.game;

  bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mess.deletegame(game.sharedData)),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: GameCard(gameUid: game.uid),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      });
  if (result) {
    gameBloc.add(SingleGameDelete());
  }
  return result;
}
