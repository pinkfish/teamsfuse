import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:fusemodel/blocs.dart';

class AddInviteToLeagueDialog extends Dialog {
  AddInviteToLeagueDialog({@required this.leagueOrTournament});

  final TextEditingController _controller = new TextEditingController();
  final Validations validations = Validations();

  final SingleLeagueOrTournamentBloc leagueOrTournament;

  static Future<bool> showAddLeagueOrTournamentInviteDialog(
      BuildContext context,
      SingleLeagueOrTournamentBloc leagueOrTournament) async {
    String email = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new AddInviteToLeagueDialog(
            leagueOrTournament: leagueOrTournament));
    if (email == null) {
      return false;
    }
    leagueOrTournament
        .dispatch(SingleLeagueOrTournamentInviteAsAdmin(email: email));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    children.add(
      Padding(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.title,
          child: Semantics(
            child: Text(Messages.of(context).addadmin),
            namesRoute: true,
          ),
        ),
      ),
    );

    children.add(
      Flexible(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          child: TextField(
            autofocus: true,
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            decoration: new InputDecoration(
              labelText: Messages.of(context).email,
            ),
          ),
        ),
      ),
    );

    children.add(ButtonTheme.bar(
      child: ButtonBar(
        children: <Widget>[
          FlatButton(
              onPressed: () {
                String str =
                    validations.validateEmail(context, _controller.text);
                if (str == null) {
                  Navigator.pop(context, _controller.text);
                } else {
                  showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => new AlertDialog(
                          title: Text(Messages.of(context).invalidemail),
                          content: Text(Messages.of(context).invalidemail),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(MaterialLocalizations.of(context)
                                  .okButtonLabel),
                              onPressed: () => Navigator.pop(context, true),
                            )
                          ],
                        ),
                  );
                }
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel)),
          FlatButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
        ],
      ),
    ));

    Widget dialogChild = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    return new Dialog(child: dialogChild);
  }
}
