import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// The tile associated with the team, shows bonus details about the
/// team.
///
class TeamTile extends StatelessWidget {
  TeamTile(this.teamUid,
      {this.popBeforeNavigate = false, this.showIconForTeam = false});

  final String teamUid;
  final bool showIconForTeam;
  final bool popBeforeNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      builder: (BuildContext c, SingleTeamBloc teamBloc) => BlocBuilder(
        bloc: teamBloc,
        builder: (BuildContext context, SingleTeamState teamState) {
          if (teamState is SingleTeamDeleted) {
            return ListTile(
                leading: Icon(Icons.delete),
                title: Text(Messages.of(context).teamdeleted));
          }
          WinRecord record;
          String seasonName = "";
          if (teamState.team.seasons
              .containsKey(teamState.team.currentSeason)) {
            record =
                teamState.team.seasons[teamState.team.currentSeason].record;
            seasonName =
                teamState.team.seasons[teamState.team.currentSeason].name;
          }
          return ListTile(
            leading: TeamImage(
              width: 40.0,
              height: 40.0,
              teamUid: teamState.team.uid,
              alignment: Alignment.centerLeft,
              showIcon: showIconForTeam,
            ),
            title: new RichText(
              text: new TextSpan(
                text: teamState.team.name,
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
                    text: teamState.isAdmin()
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
              AppRouter.instance.navigateTo(
                  context, "Team/" + teamState.team.uid,
                  transition: TransitionType.inFromRight);
            },
          );
        },
      ),
    );
  }
}
