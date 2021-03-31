import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';

///
/// Adds an invite to the league with a nice dialog box.
///
class AddInviteToLeagueDialog extends Dialog {
  /// Constructor.
  AddInviteToLeagueDialog({@required this.leagueOrTournament});

  final TextEditingController _controller = TextEditingController();
  final Validations _validations = Validations();

  /// The league or tournament to do an invite for.
  final SingleLeagueOrTournamentBloc leagueOrTournament;

  ///
  /// Shows a dialog box to do the invite to the league or tournament.
  ///
  static Future<bool> showAddLeagueOrTournamentInviteDialog(
      BuildContext context,
      SingleLeagueOrTournamentBloc leagueOrTournament) async {
    var email = await showDialog<String>(
        context: context,
        builder: (context) =>
            AddInviteToLeagueDialog(leagueOrTournament: leagueOrTournament));
    if (email == null) {
      return false;
    }
    leagueOrTournament.add(SingleLeagueOrTournamentInviteAsAdmin(email: email));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    children.add(
      Padding(
        padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headline6,
          child: Semantics(
            namesRoute: true,
            child: Text(Messages.of(context).addAdmin),
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
            decoration: InputDecoration(
              labelText: Messages.of(context).email,
            ),
          ),
        ),
      ),
    );

    children.add(ButtonBarTheme(
      child: ButtonBar(
        children: <Widget>[
          FlatButton(
              onPressed: () {
                var str = _validations.validateEmail(context, _controller.text);
                if (str == null) {
                  Navigator.pop(context, _controller.text);
                } else {
                  showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(Messages.of(context).invalidEmail),
                      content: Text(Messages.of(context).invalidEmail),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                              MaterialLocalizations.of(context).okButtonLabel),
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

    return Dialog(child: dialogChild);
  }
}
