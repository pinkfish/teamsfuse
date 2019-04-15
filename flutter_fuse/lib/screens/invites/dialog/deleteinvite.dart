import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

void showDeleteInvite(BuildContext context, SingleInviteBloc bloc) async {
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
                  new Text(mess.confirmdelete(bloc.currentState.invite)),
                ],
              ),
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
    bloc.dispatch(
        SingleInviteEventDeleteInvite(inviteUid: bloc.currentState.invite.uid));
    await for (SingleInviteState state in bloc.state) {
      if (state is SingleInviteDeleted) {
        Navigator.pop(context);
        return;
      }
      if (state is SingleInviteSaveFailed) {
        Navigator.pop(context);
        return;
      }
    }
  }
}
