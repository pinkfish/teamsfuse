import 'package:fusemodel/fusemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'gamecard.dart';
import 'dart:async';

Future<bool> deleteGameDialog(BuildContext context, Game game) async {
  Messages mess = Messages.of(context);

  bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deletegame(game.sharedData)),
          content: new Scrollbar(
            child: new SingleChildScrollView(
              child: new GameCard(game),
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
    await game.deleteFromFirestore();
  }
  return result;
}
