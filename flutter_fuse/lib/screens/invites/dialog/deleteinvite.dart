import 'package:flutter/material.dart';
import '../../../services/blocs.dart';

import '../../../services/messages.dart';

///
/// Show a dialog to delete the invite.
///
void showDeleteInvite(BuildContext context, SingleInviteBloc bloc) async {
  var mess = Messages.of(context);

  var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return AlertDialog(
          title: Text(mess.deleteinvite),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(mess.confirmdelete(bloc.state.invite)),
                ],
              ),
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
    bloc.add(SingleInviteEventDeleteInvite(inviteUid: bloc.state.invite.uid));
    /*
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

     */
  }
}
