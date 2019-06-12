import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// The tile associated with the team, shows bonus details about the
/// team.
///
class TeamTile extends StatelessWidget {
  TeamTile(this.team,
      {this.popBeforeNavigate = false, this.showIconForTeam = false});

  final Team team;
  final bool showIconForTeam;
  final bool popBeforeNavigate;

  @override
  Widget build(BuildContext context) {
    WinRecord record;
    String seasonName = "";
    if (team.seasons.containsKey(team.currentSeason)) {
      record = team.seasons[team.currentSeason].record;
      seasonName = team.seasons[team.currentSeason].name;
    }

    return new ListTile(
      leading: TeamImage(
        width: 40.0,
        height: 40.0,
        teamUid: team.uid,
        alignment: Alignment.centerLeft,
        showIcon: showIconForTeam,
      ),
      title: new RichText(
        text: new TextSpan(
          text: team.name,
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
          children: <TextSpan>[
            new TextSpan(text: "  "),
            new TextSpan(
              text: seasonName,
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(fontStyle: FontStyle.italic, fontSize: 15.0),
            ),
            new TextSpan(
              text: team.isAdmin(null)
                  ? "\n" + Messages.of(context).administrator
                  : "",
              style: Theme.of(context).textTheme.subhead.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 10.0,
                    color: Theme.of(context).primaryColorDark,
                  ),
            ),
          ],
        ),
      ),
      isThreeLine: false,
      dense: true,
      subtitle: new Text(
          record != null ? Messages.of(context).winrecord(record) : ""),
      onTap: () {
        if (popBeforeNavigate) {
          Navigator.pop(context);
        }
        AppRouter.instance.navigateTo(context, "Team/" + team.uid,
            transition: TransitionType.inFromRight);
      },
    );
  }
}
