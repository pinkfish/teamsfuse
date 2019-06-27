import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'gamecard.dart';

Future<bool> deleteGameDialog(
    BuildContext context, SingleGameBloc gameBloc) async {
  Messages mess = Messages.of(context);
  Game game = gameBloc.currentState.game;

  bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deletegame(game.sharedData)),
          content: new Scrollbar(
            child: new SingleChildScrollView(
              child: new GameCard(gameUid: game.uid),
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child:
                  new Text(MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      });
  if (result) {
    gameBloc.dispatch(SingleGameDelete());
  }
  return result;
}
