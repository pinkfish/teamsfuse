import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';

///
/// Add a divison to the league, dialog.
///
class AddDivisonDialog extends Dialog {
  final TextEditingController _controller = TextEditingController();

  ///
  /// Shows the season dialog to add a division.
  ///
  static Future<bool> showSeasonDialog(BuildContext context,
      SingleLeagueOrTournamentSeasonBloc seasonBloc) async {
    var divisonName = await showDialog<String>(
        context: context, builder: (context) => AddDivisonDialog());
    if (divisonName == null) {
      return false;
    }
    // Write it out to firestore.  Yay.
    seasonBloc
        .add(SingleLeagueOrTournamentSeasonAddDivision(name: divisonName));
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
            child: Text(Messages.of(context).addDivison),
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
              labelText: Messages.of(context).divison,
              hintText: Messages.of(context).newdivisonhint,
            ),
          ),
        ),
      ),
    );

    children.add(ButtonBarTheme(
      child: ButtonBar(
        children: <Widget>[
          FlatButton(
              onPressed: () => Navigator.pop(context, _controller.text),
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
