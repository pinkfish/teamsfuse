import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Show a dialog to add a team ot th e league or tournament divison.
///
class AddTeamDialog extends Dialog {
  final TextEditingController _controller = TextEditingController();

  /// Show a dialog to add a team.
  static Future<bool> showTeamDialog(BuildContext context,
      SingleLeagueOrTournamentDivisonBloc leagueOrTournmantDivison) async {
    var teamName = await showDialog<String>(
        context: context, builder: (context) => AddTeamDialog());
    if (teamName == null) {
      return false;
    }
    // Write it out to firestore.  Yay.
    leagueOrTournmantDivison
        .add(SingleLeagueOrTournamentDivisonAddTeam(teamName: teamName));
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
            child: Text(Messages.of(context).addTeam),
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
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: Messages.of(context).name,
              hintText: Messages.of(context).teamNameHint,
            ),
          ),
        ),
      ),
    );

    children.add(ButtonBarTheme(
      child: ButtonBar(
        children: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, _controller.text),
              child: Text(MaterialLocalizations.of(context).okButtonLabel)),
          TextButton(
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
