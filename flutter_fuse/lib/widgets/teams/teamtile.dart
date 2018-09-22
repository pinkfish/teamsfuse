import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_fuse/widgets/util/cachednetworkimage.dart';

class TeamTile extends StatelessWidget {
  final Team team;
  final bool popBeforeNavigate;

  TeamTile(this.team, {this.popBeforeNavigate = false});

  @override
  Widget build(BuildContext context) {
    WinRecord record;
    String seasonName = "";
    if (team.seasons.containsKey(team.currentSeason)) {
      record = team.seasons[team.currentSeason].record;
      seasonName = team.seasons[team.currentSeason].name;
    }

    return new ListTile(
      leading: team.photoUrl != null ? CachedNetworkImage(
        imageUrl: team.photoUrl,
        placeholder: const Icon(Icons.group),
        width: 50.0,
        height: 50.0,
      ) : const Icon(Icons.group),
      title: new RichText(
        text: new TextSpan(
          text: team.name,
          style: Theme
              .of(context)
              .textTheme
              .subhead
              .copyWith(fontWeight: FontWeight.bold, fontSize: 17.0),
          children: <TextSpan>[
            new TextSpan(text: "  "),
            new TextSpan(
              text: seasonName,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(fontStyle: FontStyle.italic, fontSize: 15.0),
            ),
            new TextSpan(
              text: team.isAdmin()
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
      dense: false,
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
