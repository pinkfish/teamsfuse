import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../blocs/singleseasonprovider.dart';
import '../blocs/singleteamprovider.dart';
import '../util/teamimage.dart';

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
      builder: (BuildContext c, SingleTeamBloc singleTeamBloc) => BlocBuilder(
        cubit: singleTeamBloc,
        builder: (BuildContext context, SingleTeamState teamState) {
          if (teamState is SingleTeamDeleted) {
            return ListTile(
                leading: Icon(Icons.delete),
                title: Text(Messages.of(context).teamdeleted));
          }
          if (teamState is SingleTeamUninitialized) {
            return ListTile(
                leading: Icon(Icons.circle),
                title: Text(Messages.of(context).loading));
          }
          print("TeamState $teamState");

          return SingleSeasonProvider(
              seasonUid: teamState.team.currentSeason,
              builder: (BuildContext c, SingleSeasonBloc seasonBloc) {
                return ListTile(
                  leading: TeamImage(
                    width: 40.0,
                    height: 40.0,
                    teamUid: teamState.team.uid,
                    alignment: Alignment.centerLeft,
                    showIcon: showIconForTeam,
                  ),
                  title: BlocBuilder(
                    cubit: seasonBloc,
                    builder:
                        (BuildContext context, SingleSeasonState seasonState) {
                      String seasonName = "";
                      if (seasonState is SingleSeasonLoaded) {
                        seasonName = seasonState.season.name;
                      }

                      return RichText(
                        text: TextSpan(
                          text: teamState.team.name,
                          style: Theme.of(context).textTheme.subhead.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 17.0),
                          children: <TextSpan>[
                            TextSpan(text: "  "),
                            TextSpan(
                              text: seasonName,
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15.0),
                            ),
                            TextSpan(
                              text: teamState.isAdmin()
                                  ? "\n" + Messages.of(context).administrator
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 10.0,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  isThreeLine: false,
                  dense: true,
                  subtitle: BlocBuilder(
                    cubit: seasonBloc,
                    builder:
                        (BuildContext context, SingleSeasonState seasonState) {
                      if (seasonState is SingleSeasonLoaded) {
                        return Text(seasonState.season.record != null
                            ? Messages.of(context)
                                .winrecord(seasonState.season.record)
                            : "");
                      }
                      return Text(Messages.of(context).loading);
                    },
                  ),
                  onTap: () {
                    if (popBeforeNavigate) {
                      Navigator.pop(context);
                    }
                    RepositoryProvider.of<fluro.Router>(context).navigateTo(
                        context, "Team/" + teamState.team.uid,
                        transition: fluro.TransitionType.inFromRight);
                  },
                );
              });
        },
      ),
    );
  }
}
