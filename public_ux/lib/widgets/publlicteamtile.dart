import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleseasonprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/teams/teamimage.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// The tile associated with the team, shows bonus details about the
/// team.
///
class PublicTeamTile extends StatelessWidget {
  /// Constructor for the team tile.
  PublicTeamTile(this.teamUid,
      {this.popBeforeNavigate = false,
      this.showIconForTeam = false,
      this.onTap,
      this.selectedTileColor,
      this.selected = false});

  /// If we shuold do something exciting with the background.
  final Color selectedTileColor;

  /// If this tile is seltected.
  final bool selected;

  /// If the team tile has been tapped.
  final GestureTapCallback onTap;

  /// The teamUid to display.
  final String teamUid;

  /// If we should show an icon for the team.
  final bool showIconForTeam;

  /// If we should pop bevbore we navigate away,
  final bool popBeforeNavigate;

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: teamUid,
      alwaysCreate: true,
      builder: (c, singleTeamBloc) => BlocBuilder(
        bloc: singleTeamBloc,
        builder: (context, teamState) {
          if (teamState is SingleTeamDeleted) {
            return ListTile(
                leading: Icon(Icons.delete),
                title: Text(Messages.of(context).teamDeleted));
          }
          if (teamState is SingleTeamUninitialized) {
            return ListTile(
                leading: Icon(Icons.circle),
                title: Text(Messages.of(context).loading));
          }

          return GestureDetector(
            onTap: onTap ??
                () {
                  if (popBeforeNavigate) {
                    Navigator.pop(context);
                  }
                  RepositoryProvider.of<fluro.FluroRouter>(context).navigateTo(
                      context, 'Team/${teamState.team.uid}',
                      transition: fluro.TransitionType.inFromRight);
                },
            child: Card(
              margin: EdgeInsets.all(5.0),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Hero(
                      tag: 'team$teamUid',
                      child: TeamImage(
                        width: 100.0,
                        height: 100.0,
                        teamUid: teamState.team.uid,
                        alignment: Alignment.centerLeft,
                        showIcon: showIconForTeam,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: teamState.team.name,
                              style: Theme.of(context).textTheme.headline5,
                              children: <TextSpan>[
                                TextSpan(text: '  '),
                              ],
                            ),
                          ),
                          SingleSeasonProvider(
                            seasonUid: teamState.team.currentSeason,
                            builder: (context, seasonBloc) => BlocBuilder(
                              bloc: seasonBloc,
                              builder: (context, seasonState) {
                                if (seasonState is SingleSeasonLoaded) {
                                  return Text(
                                    seasonState.season.record != null
                                        ? Messages.of(context).winRecord(
                                            seasonState.season.record)
                                        : '',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  );
                                }
                                return Text(Messages.of(context).loading);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                onPressed: onTap,
                                child: const Text('VIEW'),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
