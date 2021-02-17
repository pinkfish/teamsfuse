import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentprovider.dart';
import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';

///
/// Add an invite to the specific team with a nice dialog box.
///
class AddInviteToTeamDialog extends Dialog {
  final TextEditingController _controller = TextEditingController();
  final Validations _validations = Validations();
  final leagueTeamUid;

  AddInviteToTeamDialog._(this.leagueTeamUid);

  ///
  /// Shows the invite to the team dialog box.
  ///
  static Future<bool> showAddTeamInviteDialog(
      BuildContext context, SingleLeagueOrTournamentTeamBloc leagueTeam) async {
    var email = await showDialog<String>(
        context: context,
        builder: (context) =>
            AddInviteToTeamDialog._(leagueTeam.leagueTeamUid));
    if (email == null) {
      return false;
    }
    leagueTeam.add(SingleLeagueOrTournamentTeamInviteMember(email: email));
    return true;
  }

  ///
  /// Show a dialog to add an invite to the specific team.
  ///
  static Future<bool> showAddTeamInviteDialogByUid(
      BuildContext context, String leagueTeamUid) async {
    var email = await showDialog<String>(
        context: context,
        builder: (context) => AddInviteToTeamDialog._(leagueTeamUid));
    if (email == null) {
      return false;
    }
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
            child: Text(Messages.of(context).addSeason),
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
          SingleLeagueOrTournamentProvider(
            builder: (context, leagueBloc) => FlatButton(
              onPressed: () {
                var str = _validations.validateEmail(context, _controller.text);
                if (str == null) {
                  leagueBloc.add(SingleLeagueOrTournamentInviteToTeam(
                      email: _controller.text, leagueTeamUid: leagueTeamUid));

                  Navigator.pop(context, _controller.text);
                } else {
                  showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(Messages.of(context).invalidemail),
                      content: Text(Messages.of(context).invalidemail),
                      actions: <Widget>[
                        FlatButton(
                            child: Text(MaterialLocalizations.of(context)
                                .okButtonLabel),
                            onPressed: () {
                              Navigator.pop(context, true);
                            })
                      ],
                    ),
                  );
                }
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ),
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
