import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';

class AddSeasonDialog extends Dialog {
  final TextEditingController _controller = new TextEditingController();

  static Future<bool> showSeasonDialog(BuildContext context,
      SingleLeagueOrTournamentBloc leagueOrTournamentBloc) async {
    String seasonName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new AddSeasonDialog());
    if (seasonName == null) {
      return false;
    }
    leagueOrTournamentBloc
        .add(SingleLeagueOrTournamentAddSeason(name: seasonName));
    // Write it out to firestore.  Yay.
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
            child: Text(Messages.of(context).addseason),
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
            decoration: new InputDecoration(
              labelText: Messages.of(context).season,
              hintText: Messages.of(context).newseasonhint,
            ),
          ),
        ),
      ),
    );

    children.add(ButtonTheme.bar(
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

    return new Dialog(child: dialogChild);
  }
}
