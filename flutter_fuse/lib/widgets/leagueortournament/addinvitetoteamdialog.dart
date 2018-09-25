import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/services/validations.dart';

class AddInviteToTeamDialog extends Dialog {
  final TextEditingController _controller = new TextEditingController();
  final Validations validations = Validations();

  static Future<bool> showAddTeamInviteDialog(BuildContext context,
      LeagueOrTournament league, LeagueOrTournamentTeam leagueTeam) async {
    String email = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new AddInviteToTeamDialog());
    if (email == null) {
      return false;
    }
    await UserDatabaseData.instance.updateModel
        .inviteUserToLeagueTeam(league, leagueTeam, email);
    return true;
  }

  static Future<bool> showAddTeamInviteDialogByUid(
      BuildContext context, String leagueUid, String leagueTeamUid) async {
    String email = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new AddInviteToTeamDialog());
    if (email == null) {
      return false;
    }
    // Lookup the team and league.
    LeagueOrTournament league =
        await UserDatabaseData.instance.getLegueOrTournament(leagueUid);
    LeagueOrTournamentTeam leagueTeam = await UserDatabaseData
        .instance.updateModel
        .getLeagueTeamData(leagueTeamUid);
    await UserDatabaseData.instance.updateModel
        .inviteUserToLeagueTeam(league, leagueTeam, email);
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
