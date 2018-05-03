import 'package:fusemodel/fusemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';

Future<bool> deleteInviteDialog(BuildContext context, InviteToPlayer invite) async {
  Messages mess = Messages.of(context);

  bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(mess.deleteinvite),
          content: new Scrollbar(
            child: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(mess.confirmdelete(invite)),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child:
              new Text(MaterialLocalizations.of(context).okButtonLabel),
              onPressed: () {
                // Do the delete.
                Navigator.of(context).pop(true);
              },
            ),
            new FlatButton(
              child: new Text(
                  MaterialLocalizations.of(context).cancelButtonLabel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      });
  if (result) {
    await invite.firestoreDelete();
  }
  return result;
}