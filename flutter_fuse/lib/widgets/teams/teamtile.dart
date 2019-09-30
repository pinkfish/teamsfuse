import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:fusemodel/blocs.dart';

import '../blocs/singleseasonprovider.dart';

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

          return SingleSeasonProvider(
              seasonUid: teamState.team.currentSeason,
              builder: (BuildContext c, SingleSeasonBloc seasonBloc) {
                return new ListTile(
                  leading: TeamImage(
                    width: 40.0,
                    height: 40.0,
                    teamUid: teamState.team.uid,
                    alignment: Alignment.centerLeft,
                    showIcon: showIconForTeam,
                  ),
                  title: BlocBuilder(
                    bloc: seasonBloc,
                    builder:
                        (BuildContext context, SingleSeasonState seasonState) {
                      String seasonName = "";
                      if (seasonState is SingleSeasonLoaded) {
                        seasonName = seasonState.season.name;
                      }

                      return RichText(
                        text: new TextSpan(
                          text: teamState.team.name,
                          style: Theme.of(context).textTheme.subhead.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 17.0),
                          children: <TextSpan>[
                            new TextSpan(text: "  "),
                            new TextSpan(
                              text: seasonName,
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15.0),
                            ),
                            new TextSpan(
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
                    bloc: seasonBloc,
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
                    AppRouter.instance.navigateTo(
                        context, "Team/" + teamState.team.uid,
                        transition: TransitionType.inFromRight);
                  },
                );
              });
        },
      ),
    );
  }
}
